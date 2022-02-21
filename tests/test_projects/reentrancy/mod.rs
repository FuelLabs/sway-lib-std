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
