contract;

use context_testing_abi::ContextTesting;
use std::context::contract_id;
use std::token::mint;
use std::contract_id::ContractId;

abi ContextCaller {
    fn call_get_this_balance_with_coins(send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_balance_of_contract_with_coins(send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_amount_with_coins(send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_asset_id_with_coins(send_amount: u64, context_id: ContractId) -> ContractId;
    fn call_get_gas_with_coins(send_amount: u64, context_id: ContractId) -> u64;
    fn call_get_global_gas_with_coins(send_amount: u64, context_id: ContractId) -> u64;
    fn mint_coins(mint_amount: u64);
}

impl ContextCaller for Contract {
    fn call_get_this_balance_with_coins(send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);

        context_contract.get_amount{
            coins: send_amount,
            asset_id: ~ContractId::into(contract_id()),
        }()
    }

    fn call_get_balance_of_contract_with_coins(send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);

        context_contract.get_balance_of_contract{
            coins: send_amount,
            asset_id: ~ContractId::into(contract_id()),
        }(contract_id(), context_id)
    }

    fn call_get_amount_with_coins(send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);

        context_contract.get_amount{
            coins: send_amount,
            asset_id: ~ContractId::into(contract_id()),
        }()
    }

    fn call_get_asset_id_with_coins(send_amount: u64, context_id: ContractId) -> ContractId {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);

        context_contract.get_asset_id{
            coins: send_amount,
            asset_id: ~ContractId::into(contract_id()),
        }()
    }

    fn call_get_gas_with_coins(send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);

        context_contract.get_gas{
            coins: send_amount,
            asset_id: ~ContractId::into(contract_id()),
        }()
    }

    fn call_get_global_gas_with_coins(send_amount: u64, context_id: ContractId) -> u64 {
        let id = context_id.value;
        let context_contract = abi(ContextTesting, id);
        mint(send_amount);

        context_contract.get_global_gas{
            coins: send_amount,
            asset_id: ~ContractId::into(contract_id()),
        }()
    }

    fn mint_coins(mint_amount: u64) {
        mint(mint_amount)
    }
}
