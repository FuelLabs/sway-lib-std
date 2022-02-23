use fuel_tx::{Receipt, Salt, Transaction, ContractId};
use fuels_abigen_macro::abigen;
use fuels_contract::{contract::Contract, script::Script};
// use rand::rngs::StdRng;
// use fuel_types::ContractId;
// use rand::{Rng, SeedableRng};
use fuel_core::service::{Config, FuelService};
use fuel_gql_client::client::FuelClient;


#[tokio::test]
async fn is_external_from_sdk() {
    abigen!(AuthContract, "test_artifacts/auth_testing_contract/src/abi-output.json");
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_artifacts/auth_testing_contract", salt).unwrap();
    let (client, auth_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let auth_instance = AuthContract::new(compiled, client);

    println!("Auth Contract Id: {:?}", auth_id);

    let result = auth_instance
        .is_caller_external(true)
        .call()
        .await
        .unwrap();

    println!("result: {:#?}", result);

    assert_eq!(result.value, false);
}

#[tokio::test]
async fn msg_sender_from_sdk() {
    abigen!(AuthContract, "test_artifacts/auth_testing_contract/src/abi-output.json");
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_artifacts/auth_testing_contract", salt).unwrap();
    let (client, auth_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let auth_instance = AuthContract::new(compiled, client);

    println!("Auth Contract Id: {:?}", auth_id);

    // let zero_id = authcontract_mod::ContractId {
    //     value: [0u8; 32],
    // };

    let result = auth_instance
        .returns_msg_sender(true)
        .call()
        .await
        .unwrap();

    println!("Receipts: {:?}", result);

    // TODO: Fix this, should be returning a `Result`
    assert_eq!(result.value, [0u8; 32]);
}

#[tokio::test]
async fn msg_sender_from_contract() {
    abigen!(AuthCallerContract, "test_artifacts/auth_caller_contract/src/abi-output.json");
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_artifacts/auth_caller_contract", salt).unwrap();

    let (client, auth_caller_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let auth_caller_instance = AuthCallerContract::new(compiled, client.clone());
    let compiled_2 = Contract::compile_sway_contract("test_artifacts/auth_testing_contract", salt).unwrap();
    let auth_id = Contract::deploy(&compiled_2, &client).await.unwrap();

    println!("Auth Contract Id: {:?}", auth_id);
    println!("Auth Caller Contract Id: {:?}", auth_caller_id);


    // let zero_id = authcallercontract_mod::ContractId {
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

        assert_eq!(result.value, [0u8; 32]);
}

#[tokio::test]
async fn msg_sender_from_sway_script() {
    let client = setup_local_node().await;
    let compiled = Script::compile_sway_script("test_artifacts/auth_caller_script").unwrap();
    // let salt = Salt::from([0u8; 32]);
    // let compiled_2 = Contract::compile_sway_contract("test_artifacts/auth_testing_contract", salt).unwrap();
    // let auth_id = Contract::deploy(&compiled_2, &client).await.unwrap();

    let tx = Transaction::Script {
        gas_price: 0,
        gas_limit: 1_000_000,
        byte_price: 0,
        maturity: 0,
        receipts_root: Default::default(),
        script: compiled.raw,
        script_data: vec![],
        inputs: vec![],
        outputs: vec![],
        witnesses: vec![vec![].into()],
        metadata: None,
    };

    // println!("{:?}", &tx);
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

// fn new_salt() -> Salt {
//     let rng = &mut StdRng::seed_from_u64(2321u64);
//     let salt: [u8; 32] = rng.gen();
//     let salt = Salt::from(salt);
//     salt
// }

async fn setup_local_node() -> FuelClient {
    let srv = FuelService::new_node(Config::local_node()).await.unwrap();
    FuelClient::from(srv.bound_address)
}
