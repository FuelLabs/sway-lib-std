use fuel_tx::{Receipt, Salt, Transaction};
use fuels_abigen_macro::abigen;
use fuels_contract::{contract::Contract, script::Script};
use fuel_types::ContractId;
use fuel_core::service::{Config, FuelService};
use fuel_gql_client::client::FuelClient;
use fuels_signers::provider::Provider;


abigen!(AuthContract, "test_artifacts/auth_testing_contract/out/debug/auth_testing_contract-abi.json");
abigen!(AuthCallerContract, "test_artifacts/auth_caller_contract/out/debug/auth_caller_contract-abi.json");

#[tokio::test]
async fn is_external_from_internal() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::load_sway_contract("test_artifacts/auth_testing_contract/out/debug/auth_testing_contract.bin", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let auth_instance = AuthContract::new(id.to_string(), client);

    let result = auth_instance
        .is_caller_external(true)
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, false);
}

#[tokio::test]
#[should_panic]
async fn is_external_from_external() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::load_sway_contract("test_artifacts/auth_testing_contract/out/debug/auth_testing_contract.bin", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let auth_instance = AuthContract::new(id.to_string(), client);

    let result = auth_instance
        .is_caller_external(true)
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, false);
}

#[tokio::test]
async fn msg_sender_from_internal_sdk_call() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::load_sway_contract("test_artifacts/auth_testing_contract/out/debug/auth_testing_contract.bin", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let id = Contract::deploy(&compiled, &client).await.unwrap();
    let auth_instance = AuthContract::new(id.to_string(), client);

    // let zero_id = authcontract_mod::ContractId {
    //     value: [0u8; 32],
    // };

    let result = auth_instance
        .returns_msg_sender(true)
        .call()
        .await
        .unwrap();

        // TODO: Fix this, should be returning a `Result`
        assert_eq!(result.value, 2);
}

#[tokio::test]
async fn msg_sender_from_internal_contract() {
    // need to deploy 2 contracts !
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::load_sway_contract("test_artifacts/auth_caller_contract/out/debug/auth_caller_contract.bin", salt).unwrap();
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let auth_caller_id = Contract::deploy(&compiled, &client).await.unwrap();
    let auth_caller_instance = AuthCallerContract::new(auth_caller_id.to_string(), client);

    let compiled_2 = Contract::load_sway_contract("test_artifacts/auth_testing_contract/out/debug/auth_testing_contract.bin", salt).unwrap();
    let auth_id = Contract::deploy(&compiled_2, &client).await.unwrap();
    let auth_instance = AuthContract::new(auth_id.to_string(), client);

    // let _zero_id = authcallercontract_mod::ContractId {
    //     value: auth_caller_id.into(),
    // };

    // let sway_id= authcallercontract_mod::ContractId {
    //     value: auth_caller_id.into(),
    // };

    let result = auth_caller_instance
        .call_auth_contract(true)
        .call()
        .await
        .unwrap();

        assert_eq!(result.value, 2);
}

#[tokio::test]
async fn msg_sender_from_script() {
    let client = Provider::launch(Config::local_node()).await.unwrap();
    let compiled = Script::compile_sway_script("test_artifacts/auth_caller_script").unwrap();

    let tx = Transaction::Script {
        gas_price: 0,
        gas_limit: 1_000_000_000,
        maturity: 0,
        byte_price: 0,
        receipts_root: Default::default(),
        script: compiled.raw, // Here we pass the compiled script into the transaction
        script_data: vec![],
        inputs: vec![],
        outputs: vec![],
        witnesses: vec![vec![].into()],
        metadata: None,
    };

    println!("{:?}", &tx);
    let script = Script::new(tx);

    let receipts = script.call(&client).await.unwrap();

    // not sure if I need this yet... from SDK tests in calls.rs
    let expected_receipt = Receipt::Return {
        id: ContractId::new([0u8; 32]),
        val: 0,
        pc: receipts[0].pc().unwrap(),
        is: 464,
    };

    assert_eq!(expected_receipt, receipts[0]);
}
