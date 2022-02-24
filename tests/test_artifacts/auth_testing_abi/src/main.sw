library auth_testing_abi;

use std::contract_id::ContractId;

abi AuthTesting {
    fn is_caller_external(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool;
    fn returns_msg_sender(gas_: u64, amount_: u64, color_: b256, input: ()) -> b256;
}
