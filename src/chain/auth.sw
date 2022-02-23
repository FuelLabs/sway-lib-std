library auth;
//! Functionality for determining who is calling an ABI method

use ::result::Result;
use ::address::Address;
use ::contract_id::ContractId;

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
pub fn msg_sender() -> b256 {
    if caller_is_external() {
        // TODO: Add call to get_coins_owner() here when implemented,
        // Result::Err(AuthError::ContextError)
        let res: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        res
    } else {
        // Get caller's contract ID
        // let id = ~ContractId::from(asm(r1) {
        //     gm r1 i2;
        //     r1: b256
        // });
        // Result::Ok(Sender::Id(id))
        // id.value
        asm(r1) {
            gm r1 i2;
            r1: b256
        }
    }
}
