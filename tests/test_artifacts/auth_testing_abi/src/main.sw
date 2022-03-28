library auth_testing_abi;

use std::contract_id::ContractId;
use std::chain::auth::*;
use std::result::*;


abi AuthTesting {
    fn is_caller_external() -> bool;
    fn returns_msg_sender() -> Result<Sender, AuthError>;
}
