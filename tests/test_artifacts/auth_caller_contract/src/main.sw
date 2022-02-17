contract;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

abi AuthCaller {
    fn call_auth_contract(gas_: u64, amount_: u64, color_: b256, value: bool) -> ContractId;
}

impl AuthCaller for Contract {
    fn call_auth_contract(gas_: u64, amount_: u64, color_: b256, value: bool) -> ContractId {
        let auth_contract = abi(AuthTesting, 0x5ad197a654f39e2377e388ec40de7693ef2aeb313fe7f8ddc4a385fb22afebce);
        let id = auth_contract.returns_msg_sender(10000, 0, ETH_ID, true);
        id
    }
}
