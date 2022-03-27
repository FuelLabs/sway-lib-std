contract;

use auth_testing_abi::AuthTesting;
use std::contract_id::ContractId;
use std::chain::auth::*;

abi AuthCaller {
    fn call_auth_contract(auth_id: ContractId) -> ContractId;
}

impl AuthCaller for Contract {
    fn call_auth_contract(auth_id: ContractId) -> ContractId {
        let auth_contract = abi(AuthTesting, ~ContractId::into(auth_id));
        auth_contract.returns_msg_sender()
    }
}
