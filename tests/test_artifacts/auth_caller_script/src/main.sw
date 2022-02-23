script;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

// move script to test_projects/auth/src/main ?
fn main() -> b256 {
    let auth_contract = abi(AuthTesting, 0x963ded4f27ef702bcf3b1abff577f6f8ea7e9b2804c21e18287111bdfe6df763);
    let id = auth_contract.returns_msg_sender(10000, 0, ETH_ID, true);
    id
}
