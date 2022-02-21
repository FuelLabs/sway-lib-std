use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use rand::rngs::StdRng;
use rand::{Rng, SeedableRng};

// strategy
// need 2 contracts deployed
// create a method in contract A which can be reentered
// add a check in the fn which uses the stdlib is_reentrant() funtion
// make both reentrant and non-reentrant calls to this method

#[tokio::test]
async fn not_reentrant() {
    unimplemented!();
    // abigen!(TestFuelCoinContract, "test_projects/token_ops/src/abi.json",);
    // let salt = new_salt();
    // let compiled = Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    // let (client, fuelcoin_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    // let fuel_coin_instance = TestFuelCoinContract::new(compiled, client);

    // let c = testfuelcoincontract_mod::ContractId {
    //     value: fuelcoin_id.into(),
    // };

    // let balance_check_1 = ParamsGetBalance {
    //     target: fuelcoin_id.into(),
    //     asset_id: c.clone(),
    //     salt: 1u64, // temp, see: https://github.com/FuelLabs/fuels-rs/issues/89
    // };

    // let mut balance_result = fuel_coin_instance
    //     .get_balance(balance_check_1)
    //     .call()
    //     .await
    //     .unwrap();

    // assert_eq!(balance_result.value, 0);

    // fuel_coin_instance.mint_coins(11).call().await.unwrap();

    // let balance_check_2 = ParamsGetBalance {
    //     target: fuelcoin_id.into(),
    //     asset_id: c.clone(),
    //     salt: 2u64,
    // };

    // balance_result = fuel_coin_instance
    //     .get_balance(balance_check_2)
    //     .call()
    //     .await
    //     .unwrap();

    // assert_eq!(balance_result.value, 11);
}

#[tokio::test]
async fn is_reentrant() {
    abigen!(AttackerContract, "test_artifacts/reentrancy_attacker_contract/src/abi.json",);
    let salt = new_salt();
    let compiled = Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let (client, fuelcoin_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(compiled, client);
}

#[tokio::test]
async fn script_usage_of_is_reentrant() {
    unimplemented!();
}

fn new_salt() -> Salt {
    let rng = &mut StdRng::seed_from_u64(2321u64);
    let salt: [u8; 32] = rng.gen();
    let salt = Salt::from(salt);
    salt
}