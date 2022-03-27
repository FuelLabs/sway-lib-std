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

    fn returns_msg_sender() -> ContractId {
       let sender = msg_sender();
       if let Result::Ok(v) = sender {
           if let Sender::Id(i) = v {
               v
           } else {
               ~ContractId::from(ZERO)
           }
       } else {
           ~ContractId::from(ZERO)
       }
    }
}
