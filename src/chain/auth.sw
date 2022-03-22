//! Functionality for determining who is calling an ABI method.
//! As transactions in the UTXO model don't have a concept of "sender", a single Authentication mechanism won't work for all use-cases.
//! This module exposes a variety of mechanisms for Authentication depending on the situation.
library auth;


use ::b512::B512;
use ::address::Address;
use ::ecr::ec_recover_address;
use ::contract_id::ContractId;

pub enum AuthError {
    ContextError: (),
    EcRecoverError: (),
}

// TODO: use an enum instead of loose contants for these once match statements work with enum. tracked here: https://github.com/FuelLabs/sway/issues/579
const IS_CALLER_EXTERNAL = 1;
const GET_CALLER = 2;

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

/// A wrapper for ec-recover_address which is aware of the parent context and returns the appropriate result accordingly.
/// Returns Result::Error(ContextError) if the parent context is internal, otherwise returns a Result::Ok(Address) or Result::Error(EcRecoverError)
pub fn get_signer(signature: B512, msg_hash: b256) -> Result<Address, AuthError> {
   if !caller_is_external() {
        Result::Err(AuthError::ContextError)
    } else {
        let addr = ec_recover_address(signature, msg_hash);
        // TODO: refactor ec_recover functions to return Result
        Result::Ok(addr)
    }
}

/// Get the `Sender` (ie: `Address`| ContractId) from which a call was made.
/// TODO: Return a Result::Ok(Sender) or Result::Error.
pub fn msg_sender() -> b256 {
    if caller_is_external() {
        // TODO: Add call to get_coins_owner() here when implemented,
        // Result::Err(AuthError::ContextError)
        0x0000000000000000000000000000000000000000000000000000000000000000
    } else {
        // Get caller's contract ID
        let id = ~ContractId::from(asm(r1) {
            gm r1 i2;
            r1: b256
        });
        // Result::Ok(Sender::Id(id))
        id.value
    }
}
