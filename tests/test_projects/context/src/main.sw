contract;

use std::context::*;
use std::contract_id::ContractId;

pub struct ParamsContractBalance {
    asset_id: b256,
    contract_id: ContractId
}

abi ContextTesting {
  fn get_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId;
  fn get_this_balance(gas: u64, coins: u64, asset_id: b256, asset_id: b256) -> u64;
  fn get_balance_of_contract(gas: u64, coins: u64, asset_id: b256, params: ParamsContractBalance) -> u64;
  fn get_amount(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64;
  fn get_asset_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId;
  fn get_gas(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64;
  fn get_global_gas(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64;
}

impl ContextTesting for Contract {

    fn get_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId {
        contract_id()
    }

    fn get_this_balance(gas: u64, coins: u64, asset_id: b256, asset_id: b256) -> u64 {
        this_balance(asset_id)
    }

    fn get_balance_of_contract(gas: u64, coins: u64, asset_id: b256, params: ParamsContractBalance) -> u64 {
        balance_of_contract(params.asset_id, params.contract_id)
    }

    fn get_amount(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64 {
        msg_amount()
    }

    fn get_asset_id(gas: u64, coins: u64, asset_id: b256, input: ()) -> ContractId {
        msg_asset_id()
    }

    fn get_gas(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64 {
        gas()
    }

    fn get_global_gas(gas: u64, coins: u64, asset_id: b256, input: ()) -> u64 {
        global_gas()
    }
}