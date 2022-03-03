contract;

use context_testing_abi::ContextTesting;
use std::context::contract_id;

abi ContextCaller {
    fn mint_coins(gas_: u64, amount_: u64, color_: b256, mint_amount: u64);
    fn call_get_amount(gas_: u64, amount_: u64, color_: b256, mint_amount: u64) -> u64;
    fn call_get_asset_id(gas_: u64, amount_: u64, color_: b256, mint_amount: u64) -> b256;
    fn call_get_gas(gas_: u64, amount_: u64, color_: b256, mint_amount: u64) -> u64;
    fn call_get_global_gas(gas_: u64, amount_: u64, color_: b256, mint_amount: u64) -> u64;
}

impl ContextCaller for Contract {
    fn mint_coins(gas_: u64, amount_: u64, color_: b256, mint_amount: u64) {
        mint(mint_amount);
    }

    fn call_get_amount(gas_: u64, amount_: u64, color_: b256, input: ()) -> u64 {
        let context_contract = abi(ContextTesting, 0xc849809baf7fbcc79f4364a383074b3f6c9e867cacbdb9e9f3998c5d2e076a44);
        context_contract.get_amount(10000, 11, contract_id(), ())
    }

    fn call_get_asset_id(gas_: u64, amount_: u64, color_: b256, input: ()) -> b256 {
        let context_contract = abi(ContextTesting, 0xc849809baf7fbcc79f4364a383074b3f6c9e867cacbdb9e9f3998c5d2e076a44);
        context_contract.get_asset_id(10000, 11, contract_id(), ())
    }

    fn call_get_gas(gas_: u64, amount_: u64, color_: b256, input: ()) -> u64 {
        let context_contract = abi(ContextTesting, 0xc849809baf7fbcc79f4364a383074b3f6c9e867cacbdb9e9f3998c5d2e076a44);
        context_contract.get_gas(10000, 11, contract_id(), ())
    }

    fn call_get_global_gas(gas_: u64, amount_: u64, color_: b256, input: ()) -> u64 {
        let context_contract = abi(ContextTesting, 0xc849809baf7fbcc79f4364a383074b3f6c9e867cacbdb9e9f3998c5d2e076a44);
        context_contract.get_global_gas(10000, 11, contract_id(), ())
    }
}
