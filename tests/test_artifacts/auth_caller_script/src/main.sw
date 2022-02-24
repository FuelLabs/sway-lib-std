script;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

// move script to test_projects/auth/src/main ?
fn main() -> b256 {
    let auth_contract = abi(AuthTesting, 0x31339370c797efcecd4d33d4e36d95dc19479917afde2a930d44c04b37b4c368);
    let id = auth_contract.returns_msg_sender(10000, 0, ETH_ID, ());
    id
}
