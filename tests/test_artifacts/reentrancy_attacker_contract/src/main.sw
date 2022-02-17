contract;

use std::contract_id::ContractId;
use target_abi::Target;
use std::chain::auth::msg_sender;
use std::context::contract_id;
use std::constants::ETH_ID;

abi Attacker {
    fn launch_attack(gas_: u64, amount_: u64, color_: b256, target: ContractId) -> bool;
    fn launch_thwarted_attack(gas_: u64, amount_: u64, color_: b256, target: ContractId) -> bool;
    fn innocent_callback(gas_: u64, amount_: u64, color_: b256, some_value: u64) -> bool;
}

impl Attacker for Contract {
    fn launch_attack(gas_: u64, amount_: u64, color_: b256, target: ContractId) -> bool {
        let id = target.value;
        let caller = abi(Target, id);
        let result = caller.can_be_reentered(1000, 0, ETH_ID, ());
        result
    }

     fn launch_thwarted_attack(gas_: u64, amount_: u64, color_: b256, target: ContractId) -> bool {
         let id = target.value;
         let caller = abi(Target, id);
         let result = caller.reentrant_proof(1000, 0, ETH_ID, ());
         result
     }

    fn innocent_callback(gas_: u64, amount_: u64, color_: b256, some_value: u64) -> bool {
        let attack_thwarted = true;
        let target_id = msg_sender();
        let current_id = contract_id();
        let caller = abi(Attacker, current_id);
        // TODO: fix this to use the id returned by mesage_sender() !
        // type issues with that atm:
        let temp_id = ~ContractId::from(ETH_ID);
        caller.launch_attack(1000, 0, ETH_ID, target_id);
        attack_thwarted
    }
}
