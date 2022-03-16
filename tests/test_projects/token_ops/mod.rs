use fuel_core::service::Config;
use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use fuels_signers::provider::Provider;

abigen!(
    TestFuelCoinContract,
    "test_projects/token_ops/out/debug/token_ops-abi.json"
);

#[tokio::test]
async fn mint() {
    let salt = Salt::from([0u8; 32]);
    let compiled =
        Contract::load_sway_contract("test_projects/token_ops/out/debug/token_ops.bin", salt)
            .unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = TestFuelCoinContract::new(id.to_string(), client);

    let target = testfuelcoincontract_mod::ContractId { value: id.into() };
    let asset_id = testfuelcoincontract_mod::ContractId { value: id.into() };

    let mut balance_result = instance
        .get_balance(target.clone(), asset_id.clone())
        .call()
        .await
        .unwrap();
    assert_eq!(balance_result.value, 0);

    instance.mint_coins(11).call().await.unwrap();

    balance_result = instance.get_balance(target, asset_id).call().await.unwrap();
    assert_eq!(balance_result.value, 11);
}

#[tokio::test]
async fn burn() {
    let salt = Salt::from([0u8; 32]);
    let compiled =
        Contract::load_sway_contract("test_projects/token_ops/out/debug/token_ops.bin", salt)
            .unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = TestFuelCoinContract::new(id.to_string(), client);

    let target = testfuelcoincontract_mod::ContractId { value: id.into() };
    let asset_id = testfuelcoincontract_mod::ContractId { value: id.into() };

    let mut balance_result = instance
        .get_balance(target.clone(), asset_id.clone())
        .call()
        .await
        .unwrap();
    assert_eq!(balance_result.value, 0);

    instance.mint_coins(11).call().await.unwrap();
    instance.burn_coins(7).call().await.unwrap();

    balance_result = instance.get_balance(target, asset_id).call().await.unwrap();
    assert_eq!(balance_result.value, 4);
}

#[tokio::test]
async fn force_transfer() {
    let salt = Salt::from([0u8; 32]);
    let client = Provider::launch(Config::local_node()).await.unwrap();

    let compiled_fuelcoin =
    Contract::load_sway_contract("test_projects/token_ops/out/debug/token_ops.bin", salt).unwrap();
    let fuelcoin_id = Contract::deploy(&compiled_fuelcoin, &client).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(fuelcoin_id.to_string(), client.clone());

    let compiled_balance =
    Contract::load_sway_contract("test_artifacts/balance_contract/out/debug/balance_contract.bin", salt).unwrap();
    let balance_contract_id = Contract::deploy(&compiled_balance, &client).await.unwrap();

    let asset_id = testfuelcoincontract_mod::ContractId {
        value: fuelcoin_id.into(),
    };

    let target = testfuelcoincontract_mod::ContractId {
        value: balance_contract_id.into(),
    };

    let mut balance_result = fuel_coin_instance.get_balance(asset_id.clone(), asset_id.clone()).call().await.unwrap();
    assert_eq!(balance_result.value, 0);

    fuel_coin_instance
        .mint_coins(100)
        .call()
        .await
        .unwrap();

    balance_result = fuel_coin_instance.get_balance(asset_id.clone(), asset_id.clone()).call().await.unwrap();
    assert_eq!(balance_result.value, 100);

    // confirm initial balance on balance contract (recipient)
    balance_result = fuel_coin_instance.get_balance(asset_id.clone(), target.clone()).set_contracts(&[balance_contract_id]).call().await.unwrap();
    assert_eq!(balance_result.value, 0);



    let coins = 42u64;

    fuel_coin_instance
        .force_transfer_coins(coins, asset_id.clone(), target.clone())
        .set_contracts(&[fuelcoin_id, balance_contract_id])
        .call()
        .await
        .unwrap();

    // confirm remaining balance on fuelcoin contract
    balance_result = fuel_coin_instance.get_balance(asset_id.clone(), asset_id.clone()).call().await.unwrap();
    assert_eq!(balance_result.value, 58);

    // confirm new balance on balance contract (recipient)
    balance_result = fuel_coin_instance.get_balance(asset_id.clone(), target.clone()).set_contracts(&[balance_contract_id]).call().await.unwrap();
    assert_eq!(balance_result.value, 42);
}

#[tokio::test]
async fn transfer_to_output() {
    let salt = Salt::from([0u8; 32]);

    let compiled_fuelcoin =
        Contract::load_sway_contract("test_projects/token_ops/out/debug/token_ops.bin", salt)
            .unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let fuelcoin_id = Contract::deploy(&compiled_fuelcoin, &client).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(fuelcoin_id.to_string(), client);

    let target = testfuelcoincontract_mod::ContractId {
        value: fuelcoin_id.into(),
    };
    let asset_id = target.clone();

    let mut balance_result = fuel_coin_instance.get_balance(target.clone(), asset_id.clone()).call().await.unwrap();
    assert_eq!(balance_result.value, 0);

    fuel_coin_instance
        .mint_coins(100)
        .call()
        .await
        .unwrap();

    balance_result = fuel_coin_instance.get_balance(target.clone(), asset_id.clone()).call().await.unwrap();
    assert_eq!(balance_result.value, 100);

    let coins = 42u64;
    let recipient = testfuelcoincontract_mod::Address {
        value: [11u8; 32]
    };


    let result = fuel_coin_instance.transfer_coins_to_output(coins, asset_id.clone(), recipient).call().await.unwrap();
    println!("Result: {:?}", result);


    balance_result = fuel_coin_instance.get_balance(target, asset_id).call().await.unwrap();
    assert_eq!(balance_result.value, 58);

}
