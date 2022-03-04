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
pub fn msg_asset_id() -> b256 {
    asm(asset_id) {
        addi asset_id fp i32;
        asset_id: b256
    }
}

/// Get the code size in bytes (padded to word alignment) from the current call frame.
pub fn code_size() -> u64 {
    // let offset = CODE_SIZE_OFFSET;
   //               ^^^^^^^^^^^^^^^^ Internal compiler error: Unknown variable in assembly generation. This should have been an error during type checking.Please file an issue on the repository and include the code that triggered this error.
    asm(size, ptr, offset: 576) {
        add size fp offset;
        size: u64
    }
}

/// Get the first parameter from the current call frame.
pub fn first_param() -> u64 {
    // let offset = FIRST_PARAM_OFFSET;
    asm(size, ptr, offset: 584) {
        add size fp offset;
        size: u64
    }
}

/// Get the second parameter from the current call frame.
pub fn second_param() -> u64 {
    // let offset = SECOND_PARAM_OFFSET;
    asm(size, ptr, offset: 592) {
        add size fp offset;
        size: u64
    }
}
