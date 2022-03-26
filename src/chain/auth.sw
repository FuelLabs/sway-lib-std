library auth;
//! Functionality for determining who is calling a contract.

use ::address::Address;
use ::assert::assert;
use ::b512::B512;
use ::contract_id::ContractId;
use ::result::Result;

pub enum AuthError {
    ContextError: (),
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

/// Get the `Sender` (i.e. `Address`or `ContractId`) from which a call was made.
/// Returns a `Result::Ok(Sender)`, or `Result::Err(AuthError)` if a sender cannot be determined.
pub fn msg_sender() -> Result<Sender, AuthError> {
    if caller_is_external() {
        let sender_res = get_coins_owner();
        if let Result::Ok(sender) = sender_res {
            Result::Ok(sender)
        } else {
            Result::Err(AuthError::ContextError)
        }
    } else {
        // Get caller's `ContractId`.
        Result::Ok(Sender::ContractId(caller_contract_id()))
    }
}

/// If the input's type is `InputCoin`, return the owner.
/// Otherwise, undefined behavior.
fn get_input_owner(input_ptr: u32) -> Address {
    // get data offest by 1 word
    let data_ptr = asm(buffer, ptr: input_ptr, data_ptr) {
        move buffer sp;
        cfei i8;
        addi data_ptr input_ptr i8;
        mcpi buffer data_ptr i8;
        buffer: u8
    };

    let owner_addr = ~Address::from(asm(buffer, ptr: data_ptr, owner_ptr) {
        move buffer sp;
        cfei i8;
        addi owner_ptr data_ptr i16;
        mcpi buffer owner_ptr i32;
        buffer: b256
    });

    owner_addr
}

/// Get the owner of the inputs (of type `InputCoin`) to a TransactionScript,
/// if they all share the same owner.
fn get_coins_owner() -> Result<Sender, AuthError> {
    let zero_addr = ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000);
    let target_input_type = 0u8;
    let inputs_count = get_inputs_count();

    let mut candidate = zero_addr;
    let mut input_owner = zero_addr;
    let mut i = 0u64;
    let mut input_pointer: u32 = 0u32;
    let mut input_type: u8 = 0u8;

    while i < inputs_count {
        input_pointer = get_input_pointer(i);
        input_type = get_input_type(input_pointer);
        if input_type != target_input_type {
            // increment the counter and continue looping
            i = i + 1;
        } else {
            // type == InputCoin
            if candidate == zero_addr {
                // this is the first input seen of the correct type
                input_owner = get_input_owner(input_pointer);
                candidate = input_owner;
            } else {
                // compare current coin owner to candidate
                if input_owner == candidate {
                    // owners are a match, continue looping
                    i = i + 1;
                } else {
                    // owners don't match. Break and return Err
                    i = inputs_count;
                    return Result::Err(AuthError::ContextError);
                };
            };
        };
    }
    Result::Ok(Sender::Address(candidate))
}

/// Get a pointer to an input given the index of the input.
fn get_input_pointer(n: u64) -> u32 {
    // TX_START = 32 + MAX_INPUTS * (32 + 8) = 32 + 8 * (40) = 352
    // inputs   = TX_START + 12 words = 352 + 96             = 448

    let input_start = asm(r1, r2: n) {
        xis r1 r2;
        r1: u64
    };

    let input_length = asm(r1, r2: n) {
        xil r1 r2;
        r1: u64
    };

    // Inputs begin at the 12th word in a TransactionScript
    asm(buffer, start: input_start, length: input_length, inputs_ptr: 448) {
        move buffer sp;
        mcp buffer input_start input_length;
        buffer: u32
    }
}

/// Get the type (0|1) of an input given a pointer to the input.
fn get_input_type(p: u32) -> u8 {
    asm(type, ptr: p) {
        move type sp;
        cfei i32;
        mcpi type ptr i32;
        type: u8
    }
}

/// Get the number of inputs.
fn get_inputs_count() -> u64 {
    // inputsCount is the 7th word in a `TransactionScript`
    // TX_START    = 32 + MAX_INPUTS * (32 + 8) = 32 + 8 * (40) = 352
    // inputsCount = TX_START + 7 words = 352 + 56              = 408

    asm(r1, inputs_count_ptr: 408) {
        lw r1 inputs_count_ptr i0;
        r1: u64
    }
}
