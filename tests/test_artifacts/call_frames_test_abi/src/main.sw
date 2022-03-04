library call_frames_test_abi;

use std::contract_id::ContractId;

abi CallFramesTest {
    fn get_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId;
    fn get_asset_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId;
    fn get_code_size(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64;
    fn get_first_param(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64;
    fn get_second_param(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64;
}
