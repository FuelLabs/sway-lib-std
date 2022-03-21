use fuel_core::service::Config;
use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use fuels_signers::provider::Provider;


#[tokio::test]
async fn contract_id_eq_implementation() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Script::compile_sway_script("test_projects/contract_id_type").unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
}