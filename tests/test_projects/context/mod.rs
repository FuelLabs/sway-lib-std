use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;

abigen!(TestContextContract, "test_projects/context/out/debug/context-abi.json",);

#[tokio::test]
async fn get_contract_id() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = TestContextContract::new(compiled, client);

    let c = testcontextcontract_mod::ContractId {
        value: context_id.into(),
    };

    let result = context_instance
        .get_id()
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, c.value);
}

#[tokio::test]
async fn get_this_balance() {
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = TestContextContract::new(compiled, client);

    println!("Contract deployed at: {}", context_id);

    let result = context_instance
        .get_this_balance([0u8; 32])
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, 0);
}

#[tokio::test]
async fn get_balance_of_contract() {
    // let salt = Salt::from([0u8; 32]);
    // let compiled = Contract::compile_sway_contract("test_projects/token_ops", salt).unwrap();
    // let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    // let context_instance = TestContextContract::new(compiled, client);

    // let c = testcontextcontract_mod::ContractId {
    //     value: context_id.into(),
    // };

    // let result = context_instance
    //     .get_id()
    //     .call()
    //     .await
    //     .unwrap();

    // assert_eq!(result.value, c.value);
}

#[tokio::test]
async fn get_msg_value() {}

#[tokio::test]
async fn get_msg_id() {}

#[tokio::test]
async fn get_msg_gas() {}

#[tokio::test]
async fn get_global_gas() {}