library reentrancy;

use ::context::contract_id;
use ::auth::caller_is_external;
use ::option::*;


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
        // consider reversing these to check Option::Some first (for every iteration after the first caller_id will be an Option::Some() value).
        if caller_id == Option::None {
            caller_id = Option::Some(temp_caller_id);
        } else {
            if Option::Some(temp_caller_id) == caller_id {
                reentrancy = true;
                internal = false;
            } else {
                internal = !caller_is_external();
                call_frame_pointer = saved_registers_pointer + 48;
            };
        };
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
