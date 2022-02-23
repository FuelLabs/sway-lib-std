contract;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

abi AuthCaller {
    fn call_auth_contract(gas_: u64, amount_: u64, color_: b256, value: bool) -> b256;
}

impl AuthCaller for Contract {
    fn call_auth_contract(gas_: u64, amount_: u64, color_: b256, value: bool) -> b256 {
        let auth_contract = abi(AuthTesting, 0x963ded4f27ef702bcf3b1abff577f6f8ea7e9b2804c21e18287111bdfe6df763);
        let id = auth_contract.returns_msg_sender(10000, 0, ETH_ID, true);
        id
    }
}
