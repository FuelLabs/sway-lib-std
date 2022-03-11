contract;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

abi AuthCaller {
    fn call_auth_contract(auth_id: ContractId) -> ContractId;
}

impl AuthCaller for Contract {
    fn call_auth_contract(auth_id: ContractId) -> ContractId {
        let auth_contract = abi(AuthTesting, ~ContractId::into(auth_id));
        let id = auth_contract.returns_msg_sender();
        id
    }
}
