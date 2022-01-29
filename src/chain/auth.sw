library auth;
//! Functionality for determining who is calling an ABI method

use ::result::Result;
use ::address::Address;
use ::contract_id::ContractId;

// Ref: https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/opcodes.md#gm-get-metadata
pub enum GmOptions {
    IsCallerExternal: u8, // Get if caller is external.
    GetCaller: u8, // Get caller's contract ID.
}

pub enum AuthError {
    ContextError: (),
}

pub enum Sender {
    Address: Address,
    Id: ContractId,
}

/// Returns `true` if the caller is external (ie: a script or predicate).
pub fn caller_is_external() -> bool {
    let GmOne = GmOptions::IsCallerExternal(1);
    asm(r1, r2: GmOne) {
        gm r1 r2;
        r1: bool
    }
}

/// Returns a Result::Ok(Address) or Result::Error.
// NOTE: Currently only returns the Ok variant of result if the parent context is Internal.
pub fn msg_sender() -> Result<Sender, AuthError> {
    if caller_is_external() {
        // TODO: Add call to get_coins_owner() here when its implemented,
        Result::Err(AuthError::ContextError)
    } else {
        // Get caller's contract ID
        let GmTwo = GmOptions::GetCaller(2);
        let id = ~ContractId::from(asm(r1, r2: GmTwo) {
            gm r1 r2;
            r1: b256
        });
        Result::Ok(Sender::Id(id))
    }
}
