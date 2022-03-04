use fuel_core::service::Config;
use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use fuels_signers::provider::Provider;

#[tokio::test]
async fn can_get_overflow() {
    abigen!(
        CallFrameTestContract,
        "test_projects/registers/out/debug/call_frames-abi.json",
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/call_frames", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = CallFrameTestContract::new(id.to_string(), client);

    let result = instance.get_overflow().call().await.unwrap();

    assert_eq!(result.value, 0);
}
