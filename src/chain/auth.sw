library auth;
//! Functionality for determining who is calling a contract.

use ::address::Address;
use ::assert::assert;
use ::b512::B512;
use ::contract_id::ContractId;
use ::option::*;
use ::result::Result;

pub enum AuthError {
    InputsNotAllOwnedBySameAddress: (),
}

pub enum Sender {
    Address: Address,
    ContractId: ContractId,
}

/// Returns `true` if the caller is external (i.e. a script).
/// Otherwise, returns `false`.
/// ref: https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/opcodes.md#gm-get-metadata
pub fn caller_is_external() -> bool {
    asm(r1) {
        gm r1 i1;
        r1: bool
    }
}

/// If caller is internal, returns the contract ID of the caller.
/// Otherwise, undefined behavior.
pub fn caller_contract_id() -> ContractId {
    ~ContractId::from(asm(r1) {
        gm r1 i2;
        r1: b256
    })
}

/// If the input's type is `InputCoin`, return the owner.
/// Otherwise, undefined behavior.
fn get_input_owner(input_ptr: u32) -> Address {
    let owner_addr = ~Address::from(asm(buffer, ptr: input_ptr) {
        // Need to skip over six words, so add 8*6=48
        addi ptr ptr i48;
        // Save old stack pointer
        move buffer sp;
        // Extend stack by 32 bytes
        cfei i32;
        // Copy 32 bytes
        mcpi buffer ptr i32;
        // `buffer` now points to the 32 bytes
        buffer: b256
    });

    owner_addr
}

/// Get the `Sender` (i.e. `Address` or `ContractId`) from which a call was made.
/// Returns a `Result::Ok(Sender)`, or `Result::Err(AuthError)` if a sender cannot be determined.
pub fn msg_sender() -> Result<Sender, AuthError> {
    if caller_is_external() {
        let sender_res = get_coins_owner();
        if let Result::Ok(sender) = sender_res {
            Result::Ok(sender)
        } else {
            sender_res
        }
    } else {
        // Get caller's `ContractId`.
        Result::Ok(Sender::ContractId(caller_contract_id()))
    }
}

/// Get the owner of the inputs (of type `InputCoin`) to a TransactionScript,
/// if they all share the same owner.
fn get_coins_owner() -> Result<Sender, AuthError> {
    let target_input_type = 0u8;
    let inputs_count = get_inputs_count();

    let mut candidate = Option::None::<Address>();
    let mut i = 0u64;

    while i < inputs_count {
        let input_pointer = get_input_pointer(i);
        let input_type = get_input_type(input_pointer);
        if input_type != target_input_type {
            // type != InputCoin
            // Continue looping.
            i = i + 1;
        } else {
            // type == InputCoin
            let input_owner = Option::Some(get_input_owner(input_pointer));
            if candidate.is_none() {
                // This is the first input seen of the correct type.
                candidate = input_owner;
                i = i + 1;
            } else {
                // Compare current coin owner to candidate.
                // `candidate` and `input_owner` must be `Option::Some` at this point,
                // so can unwrap safely.
                if input_owner.unwrap() == candidate.unwrap() {
                    // Owners are a match, continue looping.
                    i = i + 1;
                } else {
                    // Owners don't match. Return Err.
                    i = inputs_count;
                    return Result::Err(AuthError::InputsNotAllOwnedBySameAddress);
                };
            };
        };
    }

    // `candidate` must be `Option::Some` at this point, so can unwrap safely.
    // Note: `inputs_count` is guaranteed to be at least 1 for any valid tx.
    Result::Ok(Sender::Address(candidate.unwrap()))
}

/// Get a pointer to an input given the index of the input.
fn get_input_pointer(index: u64) -> u32 {
    asm(r1, r2: index) {
        xis r1 r2;
        r1: u32
    }
}

/// Get the type (0|1) of an input given a pointer to the input.
fn get_input_type(ptr: u32) -> u8 {
    asm(r1, r2: ptr) {
        lw r1 r2 i0;
        r1: u8
    }
}

/// Get the number of inputs.
fn get_inputs_count() -> u64 {
    // `inputsCount` is the 8th word in a `TransactionScript`
    // TX_START    = 32 + MAX_INPUTS * (32 + 8) + 8 = 32 + 255 * (40) + 8 = 10240
    // inputsCount = TX_START + 7 words = 10240 + 56                      = 10296

    asm(r1, r2: 10296) {
        lw r1 r2 i0;
        r1: u64
    }
}
