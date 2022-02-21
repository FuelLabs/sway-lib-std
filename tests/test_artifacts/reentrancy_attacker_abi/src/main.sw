library reentrancy_attacker_abi;

use std::contract_id::ContractId;

abi Attacker {
    fn launch_attack(gas_: u64, amount_: u64, color_: b256, target: ContractId) -> bool;
    fn launch_thwarted_attack(gas_: u64, amount_: u64, color_: b256, target: ContractId) -> bool;
    fn innocent_callback(gas_: u64, amount_: u64, color_: b256, some_value: u64) -> bool;
}
