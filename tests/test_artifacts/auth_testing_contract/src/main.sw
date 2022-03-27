contract;

use std::result::{Result};
use std::chain::auth::*;
use std::contract_id::ContractId;
use auth::AuthTesting;


impl AuthTesting for Contract {
    fn is_caller_external() -> bool {
        caller_is_external()
    }

    /// TODO: Fix return type, supposed to be a `Result`
    fn returns_msg_sender() -> ContractId {
        msg_sender()
    }
}