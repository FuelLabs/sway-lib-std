contract;

use std::contract_id::ContractId;
use target_abi::Target;
use std::chain::auth::msg_sender;
use std::context::contract_id;
use std::constants::ETH_ID;
use attacker_abi::Attacker;


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
        let attacker_caller = abi(Attacker, current_id);
        // TODO: fix this to use the 'target_id' returned by mesage_sender()!
        // caller.launch_attack(1000, 0, ETH_ID, target_id);
        attacker_caller.launch_attack(1000, 0, ETH_ID, <TARGET_ID>);
        // consider use of 'if let' here to set value of attack_thwarted conditionally
        attack_thwarted
    }
}
