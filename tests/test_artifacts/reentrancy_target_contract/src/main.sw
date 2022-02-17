contract;

use std::reentrancy::is_reentrant;
use std::chain::panic;
use std::contract_id::ContractId;
use std::constants::ETH_ID;
use std::auth::msg_sender;
use std::context::gas;
use attacker::Attacker;
use target_abi::Target;

impl Target for Contract {
    fn can_be_reentered(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool {
        let safe_from_reentry: bool = false;
        let attacker_id = msg_sender();
        let caller = abi(Attacker, attacker_id);
        /// this call transfers control to the attacker contract, allowing it to execute arbitrary code.
        caller.innocent_callback(1000, 0, ETH_ID, 42)

        let was_reentered = is_reentrant();
        was_reentered
    }

    fn reentrant_proof(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool {
        let mut reentrant_proof = false;
        if is_reentrant() {
            reentrant_proof = true;
        }
        let attacker_id = msg_sender();
        let caller = abi(Attacker, attacker_id);
        /// this call transfers control to the attacker contract, allowing it to execute arbitrary code.
        caller.innocent_callback(1000, 0, ETH_ID, 42);
        reentrant_proof
    }
}