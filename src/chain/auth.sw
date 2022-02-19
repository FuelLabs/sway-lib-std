library auth;
//! Functionality for determining who is calling an ABI method

use ::contract_id::ContractId;
use ::address::Address;
use ::result::*;
use ::b512::B512;
use ::chain::assert;
use ::result::Result;


pub enum AuthError {
    ContextError: (),
}

pub enum Sender {
    Address: Address,
    Id: ContractId,
}

/// Returns `true` if the caller is external (ie: a script or predicate).
// ref: https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/opcodes.md#gm-get-metadata
pub fn caller_is_external() -> bool {
    asm(r1) {
        gm r1 i1;
        r1: bool
    }
}

/// Get the `Sender` (ie: `Address`| ContractId) from which a call was made.
/// Returns a Result::Ok(Sender) or Result::Error.
// NOTE: Currently only returns Result::Ok variant if the parent context is Internal.
pub fn msg_sender() -> Result<Sender, AuthError> {
    if caller_is_external() {
        let address = get_coins_owner();
        if (address == ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000)) {
            Result::Err(AuthError::ContextError)
        } else {
            Result::Some(Sender::Address(address)
        }
    } else {
        // Get caller's ContractId / TransactionId
        let id = ~ContractId::from(asm(r1) {
            gm r1 i2;
            r1: b256
        })
        Caller::Some(id)
}




// if the inputs type is InputCoin, return the owner
// note that if the input is not of the type `InputCoin` (0), there won't be an owner and this could return unexpected data
// TODO: Use Option type for the return here.
fn get_input_owner(input_ptr: u32) -> Caller {
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

        Caller::Some(owner_addr)

}

// inputsCount is the 7th word in a TransactionScript
// TX_START        = 32 + MAX_INPUTS * (32 + 8)                // 32 + 8 * (40)  == 352
// inputsCount     = TX_START + 7 words / 56 bytes             //       352 + 56 == 408
// inputs          = TX_START + 12 words / 96 bytes            //       352 + 96 == 448
/// Get the owner of the inputs(of type `InputCoin`) to a TransactionScript, if they all share the same owner.
pub fn get_coins_owner() -> Caller {
    let zero_addr = ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000);
    let target_input_type = 0u8;
    let mut candidate = ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000);
    let mut input_owner = ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000);
    let mut i = 0u8;
    let mut input_pointer: u32 = 0u32;
    let mut input_type: u8 = 0u8;
    let inputs_count = get_inputs_count(408);

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
                    // owners don't match. Break and return None
                    i = inputs_count;
                    Caller::None()
               };
            };
        };
    }
    Caller::Some(candidate)
}

// get a pointer to an input given the index of the input you're looking for
fn get_input_pointer(n: u8) -> u32 {
    let input_start = asm(r1, r2: n) {
        xis r1 r2;
        r1: u64
    };

    let input_length = asm(r1, r2: n) {
        xil r1 r2;
        r1: u64
    };

    // inputs is the 12th word in a TransactionScript
    asm(buffer, start: input_start, length: input_length, inputs_ptr: 448) {
        move buffer sp;
        mcp buffer input_start input_length;
        buffer: u32
    }
}

// get the type(0|1) of an input given a pointer to the input
fn get_input_type(p: u32) -> u8 {
    asm(type, ptr: p) {
        move type sp;
        cfei i32;
        mcpi type ptr i32;
        type: u8
    }
}

fn get_inputs_count(offset: u64) -> u64 {
    asm(r1, inputs_count_ptr: offset) {
        lw r1 inputs_count_ptr i0;
        r1: u64
    }
}
