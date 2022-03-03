//! Helper functions for accessing data from call frames.
/// Call frames store metadata across untrusted inter-contract calls:
/// https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/main.md#call-frames
library call_frames;

use ::constants::{CALL_FRAME_OFFSET, CODE_SIZE_OFFSET, FIRST_PARAM_OFFSET, SAVED_REGISTERS_OFFSET, SECOND_PARAM_OFFSET};
use ::contract_id::ContractId;

///////////////////////////////////////////////////////////
//  Accessing the current call frame
///////////////////////////////////////////////////////////

/// Get the current contract's id when called in an internal context.
/// **Note !** If called in an external context, this will **not** return a contract ID.
// @dev If called externally, will actually return a pointer to the transaction ID.
pub fn contract_id() -> b256 {
    asm() {
        fp: b256
    }
}

/// Get the asset_id of coins being sent from the current call frame.
pub fn msg_asset_id() -> ContractId {
    ~ContractId::from(asm(asset_id) {
        addi asset_id fp i32;
        asset_id: b256
    })
}

/// Get the code size in bytes (padded to word alignment) from the current call frame.
pub fn code_size() -> u64 {
    asm(size, ptr, offset: CODE_SIZE_OFFSET) {
        add size fp offset;
        size: u64
    }
}

/// Get the first parameter from the current call frame.
pub fn first_param() -> u64 {
    asm(size, ptr, offset: FIRST_PARAM_OFFSET) {
        add size fp offset;
        size: u64
    }
}

/// Get the second parameter from the current call frame.
pub fn second_param() -> u64 {
    asm(size, ptr, offset: SECOND_PARAM_OFFSET) {
        add size fp offset;
        size: u64
    }
}

///////////////////////////////////////////////////////////
//  Helper functions
///////////////////////////////////////////////////////////

/// get a pointer to the current call frame
pub fn frame_pointer() -> u64 {
    asm() {
        fp: u64
    }
}

/// Get a pointer to the previous (relative to the 'frame_pointer' param) call frame using offsets from a pointer.
pub fn previous_frame_pointer(frame_pointer: u64) -> u64 {
    let offset = SAVED_REGISTERS_OFFSET + CALL_FRAME_OFFSET;
    asm(res, ptr: frame_pointer, offset: offset) {
        add res ptr offset;
        res: u64
    }
}
