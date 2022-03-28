contract;

use auth_testing_abi::AuthTesting;
use std::contract_id::ContractId;
use std::chain::auth::*;
use std::constants::ZERO;
use std::result::*;

abi AuthCaller {
    fn call_auth_contract(auth_id: ContractId) -> ContractId;
}

impl AuthCaller for Contract {
    fn call_auth_contract(auth_id: ContractId) -> ContractId {
        let auth_contract = abi(AuthTesting, ~ContractId::into(auth_id));
        let result = auth_contract.returns_msg_sender();
        if result.is_err() {
            ~ContractId::from(ZERO)
        } else {
            let unwrapped = result.unwrap();
            if let Sender::Id(v) = unwrapped {
                v
            } else {
                ~ContractId::from(ZERO)
            }
        }
    }
}
