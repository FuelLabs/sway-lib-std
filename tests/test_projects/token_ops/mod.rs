use fuel_core::model::coin;
use fuel_gql_client::client::{FuelClient};
use fuel_tx::{Receipt, Salt};
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use rand::rngs::StdRng;
use rand::{Rng, SeedableRng};

#[tokio::test]
async fn mint() {
    let salt = new_salt();

    abigen!(
        TestFuelCoinContract,
        "test_projects/token_ops/src/abi.json",
    );

    let compiled =
    Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    // let fuelcoin_id = Contract::deploy(&compiled, &client).await.unwrap();
    let (client, fuelcoin_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    println!("Contract deployed @ {:x}", fuelcoin_id);

    let fuel_coin_instance = TestFuelCoinContract::new(compiled, client);

    let c = testfuelcoincontract_mod::ContractId {
        value: fuelcoin_id.into(),
    };

    let balance_check_1 = ParamsGetBalance {
        target: fuelcoin_id.into(),
        asset_id: c.clone(),
        salt: 1u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    let mut balance_result = fuel_coin_instance.get_balance(balance_check_1).call().await.unwrap();
    assert_eq!(balance_result.value, 0);

    fuel_coin_instance
        .mint_coins(11)
        .call()
        .await
        .unwrap();

        let balance_check_2 = ParamsGetBalance {
            target: fuelcoin_id.into(),
            asset_id: c.clone(),
            salt: 2u64,
        };

    balance_result = fuel_coin_instance.get_balance(balance_check_2).call().await.unwrap();
    assert_eq!(balance_result.value, 11);
}

#[tokio::test]
async fn burn() {
    let salt = new_salt();

    abigen!(
        TestFuelCoinContract,
        "test_projects/token_ops/src/abi.json",
    );

    let compiled =
    Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let (client, fuelcoin_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    println!("Contract deployed @ {:x}", fuelcoin_id);

    let fuel_coin_instance = TestFuelCoinContract::new(compiled, client);

    let c = testfuelcoincontract_mod::ContractId {
        value: fuelcoin_id.into(),
    };

    let balance_check_1 = ParamsGetBalance {
        target: fuelcoin_id.into(),
        asset_id: c.clone(),
        salt: 1u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    let mut balance_result = fuel_coin_instance.get_balance(balance_check_1).call().await.unwrap();
    assert_eq!(balance_result.value, 0);

    fuel_coin_instance
        .mint_coins(11)
        .call()
        .await
        .unwrap();

        fuel_coin_instance
        .burn_coins(7)
        .call()
        .await
        .unwrap();

        let balance_check_2 = ParamsGetBalance {
            target: fuelcoin_id.into(),
            asset_id: c.clone(),
            salt: 2u64,
        };

    balance_result = fuel_coin_instance.get_balance(balance_check_2).call().await.unwrap();
    assert_eq!(balance_result.value, 4);
}

#[tokio::test]
async fn force_transfer() {
    let salt = new_salt();

    abigen!(
        TestFuelCoinContract,
        "test_projects/token_ops/src/abi.json",
    );

    let compiled_fuelcoin =
    Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();

    let compiled_balance_test =
    Contract::compile_sway_contract("test_artifacts/balance_contract", salt).unwrap();

    let (client, fuelcoin_id) = Contract::launch_and_deploy(&compiled_fuelcoin).await.unwrap();
    let (_, balance_test_contract_id) = Contract::launch_and_deploy(&compiled_balance_test).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(compiled_fuelcoin, client);

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
        target: fuelcoin_id.into(),
        asset_id: f.clone(),
        salt: 3u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    balance_result = fuel_coin_instance.get_balance(balance_check_3).call().await.unwrap();
    assert_eq!(balance_result.value, 58); // this is failing with Left = 100, Right = 58

    let balance_check_4 = ParamsGetBalance {
        target: balance_test_contract_id.into(),
        asset_id: f.clone(),
        salt: 4u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    };

    balance_result = fuel_coin_instance.get_balance(balance_check_4).call().await.unwrap();
    assert_eq!(balance_result.value, 42);
}

#[tokio::test]
async fn transfer_to_output() {
    let salt = new_salt();

    abigen!(
        TestFuelCoinContract,
        "test_projects/token_ops/src/abi.json",
    );

    let compiled_fuelcoin =
    Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let (client, fuelcoin_id) = Contract::launch_and_deploy(&compiled_fuelcoin).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(compiled_fuelcoin, client);

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

    fuel_coin_instance.transfer_coins_to_output(transfer_args).call().await.unwrap();
    // TODO: add a check for balance of recipient address once capability is added to SDK
    unimplemented!("Finish this test!");

    // let coin_balance = client
    //     .coin(format!("{:#x}", utxo_id).as_str())
    //     .await
    //     .unwrap();
    // assert!(coin_balance.is_some()); // should be 42

}


fn new_salt() -> Salt {
    let rng = &mut StdRng::seed_from_u64(2321u64);
    let salt: [u8; 32] = rng.gen();
    let salt = Salt::from(salt);
    salt
}

// async fn setup_local_node() -> FuelClient {
//     let srv = FuelService::new_node(Config::local_node()).await.unwrap();
//     FuelClient::from(srv.bound_address)
// }
