library auth;
//! Functionality for determining who is calling an ABI method

use ::result::Result;
use ::address::Address;
use ::ecr::ec_recover_address;
use ::contract_id::ContractId;

pub enum AuthError {
    ContextError: (),
    EcRecoverError: (),
}

pub enum Sender {
    Addr: Address,
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
    if !caller_is_external() {
        // Get caller's contract ID
        let id = ~ContractId::from(asm(r1) {
            gm r1 i2;
            r1: b256
        });
        Result::Ok(Sender::Id(id))
    } else {
        // TODO: Add call to get_coins_owner() here when its implemented,
        Result::Err(AuthError::ContextError)
    }
}

/// A wrapper for ec-recover_address which is aware of the parent context and returns the appropriate result accordingly.
pub fn get_signer(signature: B512, msg_hash: b256) -> Result<Address, AuthError> {
   if !caller_is_external() {
        Result::Err(AuthError::EcRecoverError)
    } else {
        Result::Ok(ec_recover_address(signature, msg_hash))
    }
}
