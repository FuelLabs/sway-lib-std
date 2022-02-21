library reentrancy_target_abi;

abi Target {
    fn can_be_reentered(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool;
    fn reentrant_proof(gas_: u64, amount_: u64, color_: b256, input: ()) -> bool;
}
