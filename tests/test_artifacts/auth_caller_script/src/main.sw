script;

use auth_testing_abi::AuthTesting;
use std::contract_id::ContractId;
use std::chain::auth::*;
use std::result::*;

fn main() -> u64 {
    // TODO: ContractId for auth_testing_contract should ideally be passed to script as an arg when possible.
    let auth_contract = abi(AuthTesting, 0x46a3c6d5fd60a1653d7880ee364c9c9bc41e9cedab3616d339572e931dce5110);
    let sender_value = auth_contract.returns_msg_sender();

    let value = if let Result::Err(e) = sender_value {
        0
    } else {
        1
    };

    value
}
