contract;

use context_testing_abi::ContextTesting;
use std::context::contract_id;
use std::token::mint;
use std::contract_id::ContractId;

abi ContextCaller {
    fn call_get_this_balance_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_balance_of_contract_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_amount_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_asset_id_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> b256;
    fn call_get_gas_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_global_gas_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64;
    fn mint_coins(gas_: u64, amount_: u64, color_: b256, mint_amount: u64, mint_amount: u64);
}

impl ContextCaller for Contract {
    fn call_get_this_balance_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);
        context_contract.get_amount(10000, send_amount, contract_id(), ())
    }

    fn call_get_balance_of_contract_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);
        context_contract.get_amount(10000, send_amount, contract_id(), ())
    }

    fn call_get_amount_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);
        context_contract.get_amount(10000, send_amount, contract_id(), ())
    }

    fn call_get_asset_id_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> b256 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);
        context_contract.get_asset_id(10000, send_amount, contract_id(), ())
    }

    fn call_get_gas_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);
        context_contract.get_gas(10000, send_amount, contract_id(), ())
    }

    fn call_get_global_gas_with_coins(gas_: u64, amount_: u64, color_: b256, send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        context_contract.get_global_gas(10000, send_amount, contract_id(), ())
    }

    fn mint_coins(gas_: u64, amount_: u64, color_: b256, mint_amount: u64, mint_amount: u64) {
        mint(mint_amount)
    }
}
