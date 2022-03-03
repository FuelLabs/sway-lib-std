use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;

abigen!(TestContextContract, "test_projects/context/out/debug/context-abi.json",);

#[tokio::test]
async fn get_contract_id() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = TestContextContract::new(compiled, client);

    let c = testcontextcontract_mod::ContractId {
        value: context_id.into(),
    };

    let result = context_instance
        .get_id()
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, c.value);
}

#[tokio::test]
async fn get_this_balance() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = TestContextContract::new(compiled, client);

    println!("Contract deployed at: {}", context_id);

    let result = context_instance
        .get_this_balance([0u8; 32])
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, 0);
}

#[tokio::test]
async fn get_balance_of_contract() {
    abigen!(FuelCoin, "test_projects/token_ops/out/debug/token_ops-abi.json");
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, _context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = TestContextContract::new(compiled, client.clone());

    let compiled_2 = Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let fuelcoin_id = Contract::deploy(&compiled_2, &client).await.unwrap();


    let c = testcontextcontract_mod::ContractId {
        value: fuelcoin_id.into(),
    };

    let params = ParamsContractBalance {
        asset_id: c.value,
        contract_id: c.clone()
    };

    // mint some FuelCoin tokens, then check the balance of the FuelCoin contract for the asset_id 'fuelcoin_id'
    let fuel_coin_instance = FuelCoin::new(compiled_2, client);
    fuel_coin_instance.mint_coins(42).call().await.unwrap();

    let result = context_instance
        .get_balance_of_contract(params)
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, 42);
}

#[tokio::test]
async fn get_msg_value() {
    // create a new test_artifacts contract which can mint itself some coins and can call the context_contract
    // mint some FuelCoins, then call context_contract.msg_value() with some coins;
}

#[tokio::test]
async fn get_msg_id() {
    // mint some coins, then call context_contract.msg_id() with some coins;
}

#[tokio::test]
async fn get_msg_gas() {
    // mint some coins, then call context_contract.msg_gas() with some coins;
}

#[tokio::test]
async fn get_global_gas() {
    // mint some coins, then call context_contract.global_gas() with some coins;
}