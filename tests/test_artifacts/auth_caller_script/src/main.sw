script;

use auth_testing_abi::AuthTesting;
use std::contract_id::ContractId;
use std::chain::auth::*;
use std::result::*;

fn main() -> u64 {
    let auth_contract = abi(AuthTesting, 0x1abee6eff3cf03d9d9dfc85cb372288c44379a86d71b1e60cc7d83dacec3d14a);
    let sender_value = auth_contract.returns_msg_sender();

    let value = if let Result::Err(e) = sender_value {
        0
    } else {
        1
    };

    value
}
