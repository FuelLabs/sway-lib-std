use fuel_core::service::{Config, FuelService};
use fuel_gql_client::client::FuelClient;
use fuel_tx::{Receipt, Salt, Transaction};
use fuel_types::ContractId;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::{CompiledContract, Contract};
use fuels_contract::script::Script;
use rand::rngs::StdRng;
use rand::{Rng, SeedableRng};

#[tokio::test]
async fn mint() {
    let salt = get_new_salt();
    abigen!(
        TestFuelCoinContract,
        "test_projects/token_ops/src/abi.json",
    );
    let compiled =
    Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let (client, fuelcoin_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let fuel_coin_instance = TestFuelCoinContract::new(compiled, client);

    let default_balance_params = ParamsGetBalance {
        target: fuelcoin_id.into(),
        asset_id: fuelcoin_id,
    };

    let balance_result = fuel_coin_instance.get_balance(default_balance_params);

    let result = fuel_coin_instance
        .mint_coins(11)
        .call()
        .await
        .unwrap();

}




#[tokio::test]
async fn harness() {
    assert_eq!(true, true);
}

async fn setup_local_node() -> FuelClient {
    let srv = FuelService::new_node(Config::local_node()).await.unwrap();
    FuelClient::from(srv.bound_address)
}

fn get_new_salt() -> Salt {
    let rng = &mut StdRng::seed_from_u64(2321u64);
    let salt: [u8; 32] = rng.gen();
    let salt = Salt::from(salt);
    salt
}
