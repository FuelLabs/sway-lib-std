script;

use auth_testing_abi::AuthTesting;
use std::contract_id::ContractId;
use std::chain::auth::*;
use std::result::*;

// TODO: move script to test_projects/auth/src/main
fn main() -> Result<Sender, AuthError> {
    // TODO: remove use of hardcoded id
    let auth_contract = abi(AuthTesting, 0x1abee6eff3cf03d9d9dfc85cb372288c44379a86d71b1e60cc7d83dacec3d14a);
    auth_contract.returns_msg_sender()
}
