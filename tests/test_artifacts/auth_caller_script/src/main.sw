script;

use auth::AuthTesting;
use std::contract_id::ContractId;
use std::constants::ETH_ID;

// move script to test_projects/auth/src/main ?
fn main() -> b256 {
    let auth_contract = abi(AuthTesting, 0x1abee6eff3cf03d9d9dfc85cb372288c44379a86d71b1e60cc7d83dacec3d14a);
    let id = auth_contract.returns_msg_sender(10000, 0, ETH_ID, true);
    id
}
