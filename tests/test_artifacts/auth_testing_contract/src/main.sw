contract;

use std::chain::auth::*;
use std::contract_id::ContractId;
use auth_testing_abi::AuthTesting;
use std::constants::ZERO;
use std::result::*;

impl AuthTesting for Contract {
    fn is_caller_external() -> bool {
        caller_is_external()
    }

    fn returns_msg_sender() -> Result<ContractId, AuthError> {
        msg_sender()
    }
}
