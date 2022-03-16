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
    Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let fuelcoin_id = Contract::deploy(&compiled_fuelcoin, &client).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(fuelcoin_id.to_string(), client);

    let compiled_balance =
    Contract::compile_sway_contract("test_artifacts/balance_contract", salt).unwrap();
    let balance_contract_id = Contract::deploy(&compiled_balance, &client).await.unwrap();

    println!("Contract deployed @ {:x}", fuelcoin_id);
    println!("Contract deployed @ {:x}", balance_contract_id);

    let f = testfuelcoincontract_mod::ContractId {
        value: fuelcoin_id.into(),
    };

    let b = testfuelcoincontract_mod::ContractId {
        value: balance_test_contract_id.into(),
    };

    let balance_check_1 = ParamsGetBalance {
        target: balance_test_contract_id.into(),
        asset_id: f.clone(),
        salt: 1u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    let force_transfer_args = ParamsForceTransfer {
        coins: 42u64,
        asset_id: f.clone(),
        target: b,
    };

    let mut balance_result = fuel_coin_instance.get_balance(balance_check_1).call().await.unwrap();
    assert_eq!(balance_result.value, 0);

    fuel_coin_instance
        .mint_coins(100)
        .call()
        .await
        .unwrap();

    let balance_check_2 = ParamsGetBalance {
        target: fuelcoin_id.into(),
        asset_id: f.clone(),
        salt: 2u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    balance_result = fuel_coin_instance.get_balance(balance_check_2).call().await.unwrap();
    assert_eq!(balance_result.value, 100);

    fuel_coin_instance
        .force_transfer_coins(force_transfer_args)
        .call()
        .await
        .unwrap();

    let balance_check_3 = ParamsGetBalance {
        target: balance_contract_id.into(),
        asset_id: f.clone(),
        salt: 3u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    balance_result = fuel_coin_instance.get_balance(balance_check_3).call().await.unwrap();
    assert_eq!(balance_result.value, 42);
}

#[tokio::test]
async fn transfer_to_output() {
    let salt = Salt::from([0u8; 32]);
    let client = Provider::launch(Config::local_node()).await.unwrap();

    let compiled_fuelcoin =
    Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let fuelcoin_id = Contract::deploy(&compiled_fuelcoin, &client).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(fuelcoin_id.to_string(), client);

    let f = testfuelcoincontract_mod::ContractId {
        value: fuelcoin_id.into(),
    };

    let a = testfuelcoincontract_mod::Address {
        value: [11u8; 32]
    };

    let balance_check_1 = ParamsGetBalance {
        target: fuelcoin_id.into(),
        asset_id: f.clone(),
        salt: 1u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    let mut balance_result = fuel_coin_instance.get_balance(balance_check_1).call().await.unwrap();
    assert_eq!(balance_result.value, 0);

    fuel_coin_instance
        .mint_coins(100)
        .call()
        .await
        .unwrap();

    let balance_check_2 = ParamsGetBalance {
        target: fuelcoin_id.into(),
        asset_id: f.clone(),
        salt: 2u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    balance_result = fuel_coin_instance.get_balance(balance_check_2).call().await.unwrap();
    assert_eq!(balance_result.value, 100);

    let transfer_args = ParamsTransferToOutput {
        coins: 42u64,
        asset_id: f.clone(),
        recipient: a,
    };

    let result = fuel_coin_instance.transfer_coins_to_output(transfer_args).call().await.unwrap();
    println!{"RES: {:?}", result.value};
    println!{"RES: {:?}", result.receipts};

    // let coin_balance = client
    //     .coin(format!("{:#x}", utxo_id).as_str())
    //     .await
    //     .unwrap();
    // assert!(coin_balance.is_some()); // should be 42

}
