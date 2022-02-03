//! A reentrancy guard for use in Sway contracts.
//! Note that this only works in internal contexts.

library reentrancy;

use ::context::contract_id;
use ::auth::caller_is_external;
use ::option::*;

/// Returns `true` if the reentrancy pattern is detected, and `false` otherwise.
pub fn is_reentrant() -> bool {
    let mut reentrancy = false;
    let mut internal = !caller_is_external();

    // not sure about this yet
    let mut call_frame_pointer = asm() {
        fp: u64
    }

    let mut caller_id = Option::None();

    while internal {
        let saved_registers_pointer = get_saved_regs_pointer(call_frame_pointer);
        let temp_caller_id = get_previous_caller_id(saved_registers_pointer)
        // cleanup match syntax when match for enums lands
        match caller_id {
          Option::Some(_) => {
              if Option::Some(temp_caller_id) == caller_id {
                reentrancy = true;
                internal = false;
            } else {
                internal = !caller_is_external();
                call_frame_pointer = saved_registers_pointer + 48;
            };
          },
          _ => {caller_id = Option::Some(temp_caller_id);}
        }
    }
    reentrancy
}

const SAVED_REGISTERS_OFFSET = 64; // 8 words * 8 bytes
const CALL_FRAME_OFFSET = 48;      // 6 words * 8 bytes

fn get_saved_regs_pointer(frame_ptr: u64) -> u64 {
    asm(res, pointer: frame_ptr, offset: SAVED_REGISTERS_OFFSET) {
        add res pointer offset;
        res:  u64
    }
}

fn get_previous_caller_id(saved_regs_ptr: u64) -> ContractId {
    asm(res, offset: CALL_FRAME_OFFSET) {
        add id fp offset;
        res: ContractId
    }
}
