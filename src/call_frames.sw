//! Helper functions for accessing data from call frames.
/// Call frames store metadata across untrusted inter-contract calls:
/// https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/main.md#call-frames
library call_frames;

use ::constants::{SAVED_REGISTERS_OFFSET,CALL_FRAME_OFFSET};


/// Get the value of the `ContractId` from the previous call frame on the stack.
fn get_previous_contract_id(previous_frame_ptr: u64) -> ContractId {
    ~ContractId::from(asm(res, ptr: previous_frame_ptr) {
        ptr: b256
    })
}

/// Get a pointer to the previous (relative to the 'frame_pointer' param) call frame using offsets from a pointer.
fn get_previous_frame_pointer(frame_pointer: u64) -> u64 {
    let offset = SAVED_REGISTERS_OFFSET + CALL_FRAME_OFFSET;
    asm(res, ptr: frame_pointer, offset: offset) {
        add res ptr offset;
        res: u64
    }
}

