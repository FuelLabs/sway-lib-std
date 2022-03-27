contract;

use auth_testing_abi::AuthTesting;
use std::contract_id::ContractId;
use std::result::*;
use std::chain::auth::*;

abi AuthCaller {
    fn call_auth_contract(auth_id: ContractId) -> Result<Sender, AuthError>;
}

impl AuthCaller for Contract {
    fn call_auth_contract(auth_id: ContractId) -> Result<Sender, AuthError> {
        let auth_contract = abi(AuthTesting, ~ContractId::into(auth_id));
        let id = auth_contract.returns_msg_sender();
        id
    }
}
