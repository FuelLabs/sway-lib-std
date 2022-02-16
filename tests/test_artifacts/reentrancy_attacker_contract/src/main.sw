contract;

use std::reentrancy::is_reentrant;



abi Target {
    fn can_be_reentered(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool;
}

impl Target for Contract {
    fn can_be_reentered(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool {
        let safe_from_reentry: bool = false;
        // call attacker contract:

        let was_reentered = is_reentrant();
        was_reentered
    }
}