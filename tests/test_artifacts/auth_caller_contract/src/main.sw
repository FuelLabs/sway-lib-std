contract;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

abi AuthCaller {
    fn call_auth_contract(gas_: u64, amount_: u64, color_: b256, input: ()) -> b256;
}

impl AuthCaller for Contract {
    fn call_auth_contract(gas_: u64, amount_: u64, color_: b256, input: ()) -> b256 {
        let auth_contract = abi(AuthTesting, 0x31339370c797efcecd4d33d4e36d95dc19479917afde2a930d44c04b37b4c368);
        let id = auth_contract.returns_msg_sender(10000, 0, ETH_ID, ());
        id
    }
}
