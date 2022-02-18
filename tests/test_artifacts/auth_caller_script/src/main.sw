script;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

fn main() -> u64 {
    let auth_contract = abi(AuthTesting, 0xe8f70d293feaa4c1eaaabdd2062e56c8c903a5ba3408648c3b52cc7064f5fbe0);
    let id = auth_contract.returns_msg_sender(10000, 0, ETH_ID, true);
    id

}
