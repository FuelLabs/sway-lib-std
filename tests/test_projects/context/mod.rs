use fuel_tx::{ContractId, Salt};
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use fuels_contract::parameters::TxParameters;
use fuels_signers::util::test_helpers::setup_test_provider_and_wallet;


abigen!(
    TestContextContract,
    "test_projects/context/out/debug/context-abi.json",
);
abigen!(
    TestContextCallerContract,
    "test_artifacts/context_caller_contract/out/debug/context_caller_contract-abi.json",
);
abigen!(
    FuelCoin,
    "test_projects/token_ops/out/debug/token_ops-abi.json"
);


async fn get_context() -> (
    TestContextContract,
    ContractId,
) {
    let salt = Salt::from([0u8; 32]);
    let compiled =
        Contract::load_sway_contract("test_projects/context/out/debug/context.bin", salt).unwrap();
    let (provider, wallet) = setup_test_provider_and_wallet().await;

    let contract_id = Contract::deploy(&compiled, &provider, &wallet, TxParameters::default())
        .await
        .unwrap();
    let instance =
        TestContextContract::new(contract_id.to_string(), provider.clone(), wallet.clone());

    (instance, contract_id)
}

async fn get_caller() -> (
    TestContextCallerContract,
    ContractId,
) {
    let salt = Salt::from([0u8; 32]);
    let (provider, wallet) = setup_test_provider_and_wallet().await;

    let compiled = Contract::load_sway_contract(
        "test_artifacts/context_caller_contract/out/debug/context_caller_contract.bin",
        salt,
    )
    .unwrap();
    let contract_id = Contract::deploy(&compiled, &provider, &wallet, TxParameters::default())
        .await
        .unwrap();
    let instance = TestContextCallerContract::new(contract_id.to_string(), provider, wallet);

    (instance, contract_id)
}

#[tokio::test]
async fn can_get_this_balance() {
    let (context_instance, context_id) = get_context().await;
    let (caller_instance, caller_id) = get_caller().await;
    let send_amount = 42;

    let context_sway_id = testcontextcallercontract_mod::ContractId {
        value: context_id.into(),
    };

    let caller_sway_id = testcontextcontract_mod::ContractId {
        value: caller_id.into(),
    };

    caller_instance
        .call_get_this_balance_with_coins(send_amount, context_sway_id)
        .set_contracts(&[context_id])
        .tx_params(TxParameters::new(None, Some(1_000_000), None))
        .call()
        .await
        .unwrap();

    let result = context_instance
        .get_this_balance(caller_sway_id)
        // .tx_params(TxParameters::new(None, Some(1_000_000), None))
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, send_amount);
}

#[tokio::test]
async fn can_get_balance_of_contract() {
    let (_context_instance, context_id) = get_context().await;
    let (caller_instance, caller_id) = get_caller().await;

    let amount = 42;
    caller_instance.mint_coins(amount).call().await.unwrap();
    let target = testcontextcallercontract_mod::ContractId {
        value: caller_id.into(),
    };

    let result = caller_instance
        .call_get_balance_of_contract_with_coins(amount, target)
        .set_contracts(&[context_id])
        .call()
        .await
        .unwrap();

    // let result = context_instance
    //     .get_balance_of_contract(asset_id.clone(), asset_id.clone())
    //     .set_contracts(&[context_id, caller_id])
    //     .call()
    //     .await
    //     .unwrap();

    assert_eq!(result.value, 42);
}

#[tokio::test]
async fn can_get_msg_value() {
    let (_, context_id) = get_context().await;
    let (caller_instance, _) = get_caller().await;
    let send_amount = 11;

    let context_sway_id = testcontextcallercontract_mod::ContractId {
        value: context_id.into(),
    };

    let result = caller_instance
        .call_get_amount_with_coins(send_amount, context_sway_id)
        .set_contracts(&[context_id])
        .call()
        .await
        .unwrap();
    assert_eq!(result.value, send_amount);
}

#[tokio::test]
async fn can_get_msg_id() {
    let (_context_instance, context_id) = get_context().await;
    let (caller_instance, caller_id) = get_caller().await;
    let send_amount = 42;
    let caller_sway_id = testcontextcallercontract_mod::ContractId {
        value: caller_id.into(),
    };

    let result = caller_instance
        .call_get_asset_id_with_coins(send_amount, caller_sway_id.clone())
        .set_contracts(&[context_id])
        .call()
        .await
        .unwrap();
    assert_eq!(result.value, caller_sway_id);
}

#[tokio::test]
async fn can_get_msg_gas() {
    // let (_, context_id) = get_context().await;
    // let (caller_instance, caller_id) = get_caller().await;

    let salt = Salt::from([0u8; 32]);
    let (provider, wallet) = setup_test_provider_and_wallet().await;

    let compiled_context =
        Contract::load_sway_contract("test_projects/context/out/debug/context.bin", salt).unwrap();
    let context_id = Contract::deploy(&compiled_context, &provider, &wallet, TxParameters::default())
        .await
        .unwrap();

    let compiled_caller = Contract::load_sway_contract(
        "test_artifacts/context_caller_contract/out/debug/context_caller_contract.bin",
        salt,
    )
    .unwrap();
    let caller_id = Contract::deploy(&compiled_caller, &provider, &wallet, TxParameters::default())
        .await
        .unwrap();
    let caller_instance = TestContextCallerContract::new(caller_id.to_string(), provider, wallet);

    let send_amount = 11;
    let caller_sway_id = testcontextcallercontract_mod::ContractId {
        value: caller_id.into(),
    };

    let result = caller_instance
        .call_get_gas_with_coins(send_amount, caller_sway_id)
        .set_contracts(&[context_id])
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, 11);
}

#[tokio::test]
async fn can_get_global_gas() {
    let (_context_instance, context_id) = get_context().await;
    let (caller_instance, caller_id) = get_caller().await;
    let send_amount = 11;
    let caller_sway_id = testcontextcallercontract_mod::ContractId {
        value: caller_id.into(),
    };

    let result = caller_instance
        .call_get_global_gas_with_coins(send_amount, caller_sway_id)
        .set_contracts(&[context_id])
        .call()
        .await
        .unwrap();

    assert_eq!(result.value, 11);
}
