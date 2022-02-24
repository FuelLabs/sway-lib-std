use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;

#[tokio::test]
#[ignore]
async fn can_get_contract_id() {
    abigen!(
        ContextTestingContract,
        "test_projects/context/src/abi-output.json"
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = ContextTestingContract::new(compiled, client);

    let c = contexttestingcontract_mod::ContractId {
        value: context_id.into(),
    };

    let receipts = context_instance.get_id().call().await.unwrap();

    assert_eq!(receipts.value, c);
}

// memory overflow !!!
#[tokio::test]
async fn can_get_this_balance() {
    abigen!(
        ContextTestingContract,
        "test_projects/context/src/abi-output.json"
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, _context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = ContextTestingContract::new(compiled, client);

    const ETH_ID: [u8; 32] = [0u8; 32];

    let receipts = context_instance
        .get_this_balance(ETH_ID)
        .call()
        .await
        .unwrap();

    assert_eq!(receipts.value, 0);
}

#[tokio::test]
async fn can_get_balance_of_contract() {
    abigen!(
        ContextTestingContract,
        "test_projects/context/src/abi-output.json"
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = ContextTestingContract::new(compiled, client);

    const ETH_ID: [u8; 32] = [0u8; 32];

    let c = contexttestingcontract_mod::ContractId {
        value: context_id.into(),
    };

    let my_params = ParamsContractBalance {
        asset_id: ETH_ID,
        contract_id: c,
    };

    let receipts = context_instance
        .get_balance_of_contract(my_params)
        .call()
        .await
        .unwrap();

    assert_eq!(receipts.value, 0);
}

#[tokio::test]
async fn can_get_amount() {
    abigen!(
        ContextTestingContract,
        "test_projects/context/src/abi-output.json"
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, _context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = ContextTestingContract::new(compiled, client);

    let receipts = context_instance.get_amount().call().await.unwrap();

    assert_eq!(receipts.value, 0);
}

#[tokio::test]
#[ignore]
async fn can_get_asset_id() {
    abigen!(
        ContextTestingContract,
        "test_projects/context/src/abi-output.json"
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = ContextTestingContract::new(compiled, client);

    let c = contexttestingcontract_mod::ContractId {
        value: context_id.into(),
    };

    let receipts = context_instance.get_asset_id().call().await.unwrap();

    assert_eq!(receipts.value, c);
}

#[tokio::test]
async fn can_get_context_gas_remaining() {
    abigen!(
        ContextTestingContract,
        "test_projects/context/src/abi-output.json"
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, _context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = ContextTestingContract::new(compiled, client);

    let receipts = context_instance.get_gas().call().await.unwrap();
    // brittle ? calculate what the expected value should be
    assert_eq!(receipts.value, 999722);
}

#[tokio::test]
async fn can_get_global_gas_remaining() {
    abigen!(
        ContextTestingContract,
        "test_projects/context/src/abi-output.json"
    );
    let salt = Salt::from([0u8; 32]);
    let compiled = Contract::compile_sway_contract("test_projects/context", salt).unwrap();
    let (client, _context_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let context_instance = ContextTestingContract::new(compiled, client);

    let receipts = context_instance.get_global_gas().call().await.unwrap();
    // brittle ? calculate what the expected value should be
    assert_eq!(receipts.value, 999694);
}
