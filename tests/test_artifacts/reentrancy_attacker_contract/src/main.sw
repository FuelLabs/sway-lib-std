contract;

use std::reentrancy::is_reentrant;
use std::chain::panic;



abi Target {
    fn can_be_reentered(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool;
    fn reverts_if_reentered(gas_: u64, amount_: u64, color_: b256, input: ());
}

impl Target for Contract {
    fn can_be_reentered(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool {
        let safe_from_reentry: bool = false;
        // call attacker contract here...
        let was_reentered = is_reentrant();
        was_reentered
    }

    fn reverts_if_reentered(gas_: u64, amount_: u64, color_: b256, input: ()) {
        // call attacker contract
        // then:
        if is_reentrant() {
            panic(0);
        }
    }
}