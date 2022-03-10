use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use fuel_core::service::Config;
use fuels_signers::provider::Provider;

abigen!(TestContextContract, "test_projects/context/out/debug/context-abi.json",);
abigen!(TestContextCallerContract, "test_artifacts/context_caller_contract/out/debug/context_caller_contract-abi.json",);
abigen!(FuelCoin, "test_projects/token_ops/out/debug/token_ops-abi.json");


#[tokio::test]
async fn can_get_this_balance() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let context_id = Contract::deploy(&compiled, &client).await.unwrap();
    let context_instance = TestContextContract::new(context_id.to_string(), client);

    let compiled_2 = Contract::compile_sway_contract("test_artifacts/context_caller_contract", salt).unwrap();
    let caller_id = Contract::deploy(&compiled_2, &client).await.unwrap();
    let caller_instance = TestContextCallerContract::new(caller_id.to_string(), client);

    let context_contract_id: [u8; 32] = context_id.into();
    let send_amount = 42;

    caller_instance.call_get_this_balance_with_coins(send_amount, context_contract_id).call().await.unwrap();

    // TODO: refactor to use `set_contracts(&[contract_id]) when it lands!
    let result = context_instance
        .get_this_balance(context_contract_id)
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, send_amount);
}

#[tokio::test]
async fn can_get_balance_of_contract() {
    // use context_caller to mint some coins
    // call context and get_balance_of_contract for context_caller contract.
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let context_id = Contract::deploy(&compiled, &client).await.unwrap();
    let context_instance = TestContextContract::new(context_id.to_string(), client.clone());

    let compiled_2 = Contract::compile_sway_contract("test_artifacts/context_caller_contract", salt).unwrap();
    let caller_id = Contract::deploy(&compiled_2, &client).await.unwrap();
    let caller_instance = TestContextCallerContract::new(caller_id.to_string(), client);

    let caller_contract_id: [u8; 32] = caller_id.into();
    let amount = 42;

    caller_instance.mint_coins(amount).call().await.unwrap();

    let c = testcontextcontract_mod::ContractId { value: caller_contract_id.into() };

    let result = context_instance
        .get_balance_of_contract(caller_contract_id, c)
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, 42);
}

#[tokio::test]
async fn can_get_msg_value() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_artifacts/context_caller_contract", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = TestContextCallerContract::new(id.to_string(), client);

    let send_amount = 11;
    let contract_id: [u8; 32] = id.into();

    let result = instance.call_get_amount_with_coins(send_amount, contract_id).call().await.unwrap();

    assert_eq!(result.value, send_amount);
}

#[tokio::test]
async fn can_get_msg_id() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_artifacts/context_caller_contract", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = TestContextCallerContract::new(id.to_string(), client);

    let send_amount = 42;
    let contract_id: [u8; 32] = id.into();

    let result = instance.call_get_asset_id_with_coins(send_amount, contract_id).call().await.unwrap();
    let asset_id: [u8; 32] = id.into();
    assert_eq!(result.value, asset_id);
}

#[tokio::test]
async fn can_get_msg_gas() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_artifacts/context_caller_contract", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = TestContextCallerContract::new(id.to_string(), client);

    let send_amount = 11;
    let contract_id: [u8; 32] = id.into();

    let result = instance.call_get_amount_with_coins(send_amount, contract_id).call().await.unwrap();

    assert_eq!(result.value, 11);
}

#[tokio::test]
async fn can_get_global_gas() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_artifacts/context_caller_contract", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = TestContextCallerContract::new(id.to_string(), client);

    let send_amount = 11;
    let contract_id: [u8; 32] = id.into();

    // TODO: refactor to use `set_contracts(&[contract_id]) when it lands!
    let result = instance.call_get_amount_with_coins(send_amount, contract_id).call().await.unwrap();

    assert_eq!(result.value, 11);
}
