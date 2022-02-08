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

// TODO: use an enum instead of loose contants for these once match statements work with enum.
/// tracked here: https://github.com/FuelLabs/sway/issues/579
const IS_CALLER_EXTERNAL = 1;
const GET_CALLER = 2;

pub enum Sender {
    Address: Address,
    Id: ContractId,
}

/// Returns `true` if the caller is external (ie: a script or predicate).
pub fn caller_is_external() -> bool {
    asm(r1, r2: IS_CALLER_EXTERNAL) {
        gm r1 r2;
        r1: bool
    }
}

/// A wrapper for ec-recover_address which is aware of the parent context and returns the appropriate result accordingly.
pub fn get_signer(signature: B512, msg_hash: b256) -> Result<Address, AuthError> {
   if !caller_is_external() {
        Result::Err(AuthError::EcRecoverError)
    } else {
        let addr = ec_recover_address(signature, msg_hash);
        // TODO: refactor ec_recover functions to return Result
        Result::Ok(addr)
    }
}

/// Get the `Sender` (ie: `Address`| ContractId) from which a call was made.
/// Returns a Result::Ok(Sender) or Result::Error.
// NOTE: Currently only returns Result::Ok variant if the parent context is Internal.
pub fn msg_sender() -> Result<Sender, AuthError> {
    if caller_is_external() {
        // TODO: Add call to get_coins_owner() here when implemented,
        Result::Err(AuthError::ContextError)
    } else {
        // Get caller's contract ID
        let id = ~ContractId::from(asm(r1, r2: GET_CALLER) {
            gm r1 r2;
            r1: b256
        });
        Result::Ok(Sender::Id(id))
    }
}
