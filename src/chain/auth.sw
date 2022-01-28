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
pub fn caller_is_external() -> bool {
    asm(r1) {
        gm r1 i1;
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
        let id = ~ContractId::from(asm(r1) {
            gm r1 i2;
            r1: b256
        });
        Result::Ok(Sender::Id(id))
    }
}
