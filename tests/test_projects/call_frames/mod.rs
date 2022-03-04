use fuel_core::service::Config;
use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use fuels_signers::provider::Provider;

abigen!(
    CallFramesTestContract,
    "test_projects/call_frames/out/debug/call_frames-abi.json"
);

#[tokio::test]
async fn can_get_contract_id() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/call_frames", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = CallFramesTestContract::new(id.to_string(), client);

    println!("Contract deployed at: {:#?}", id);

    let c = callframestestcontract_mod::ContractId {
        value: id.into(),
    };

    let result = instance
        .get_id()
        .call()
        .await
        .unwrap();
    // println!("result: {:#?}", result);


    assert_eq!(result.value, c);
}

#[tokio::test]
async fn can_get_msg_asset_id() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/call_frames", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = CallFramesTestContract::new(id.to_string(), client);

    let result = instance
        .get_id()
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, x);
}

#[tokio::test]
async fn can_get_code_size() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/call_frames", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = CallFramesTestContract::new(id.to_string(), client);

    let result = instance
        .get_id()
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, x);
}

#[tokio::test]
async fn can_get_first_param() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/call_frames", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = CallFramesTestContract::new(id.to_string(), client);

    let result = instance
        .get_id()
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, x);
}

#[tokio::test]
async fn can_get_msg_second_param() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/call_frames", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let instance = CallFramesTestContract::new(id.to_string(), client);

    let result = instance
        .get_id()
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, x);
}
