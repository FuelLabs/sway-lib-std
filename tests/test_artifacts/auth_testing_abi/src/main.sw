library auth_testing_abi;

use std::contract_id::ContractId;

abi AuthTesting {
    fn is_caller_external() -> bool;
    fn returns_msg_sender() -> ContractId;
}
