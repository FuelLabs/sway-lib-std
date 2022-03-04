contract;

use std::contract_id::ContractId;
use call_frames_test_abi::CallFramesTest;
use std::context::call_frames::*;

impl CallFramesTest for Contract {

    fn get_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId {
        contract_id()
    }

    fn get_asset_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId {
        msg_asset_id()
    }

    fn get_code_size(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64 {
        code_size()
    }

    fn get_first_param(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64 {
        first_param()
    }

    fn get_second_param(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64 {
        second_param()
    }

}
