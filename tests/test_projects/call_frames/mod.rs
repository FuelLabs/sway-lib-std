use fuel_tx::{ContractId, Salt};
use fuel_vm::consts::VM_MAX_RAM;
use fuels_abigen_macro::abigen;
use fuels_contract::{contract::Contract, parameters::TxParameters};
use fuels_signers::util::test_helpers;

abigen!(
    CallFramesTestContract,
    "test_projects/call_frames/out/debug/call_frames-abi.json"
);

async fn get_call_frames_instance() -> (CallFramesTestContract, ContractId) {
    let salt = Salt::from([0u8; 32]);
    let compiled =
        Contract::load_sway_contract("test_projects/call_frames/out/debug/call_frames.bin", salt)
            .unwrap();
    let (provider, wallet) = test_helpers::setup_test_provider_and_wallet().await;
    let id = Contract::deploy(&compiled, &provider, &wallet, TxParameters::default())
        .await
        .unwrap();
    let instance = CallFramesTestContract::new(id.to_string(), provider, wallet);

    (instance, id)
}

#[tokio::test]
async fn can_get_contract_id() {
    let (instance, id) = get_call_frames_instance().await;
    let c = callframestestcontract_mod::ContractId { value: id.into() };
    let result = instance.get_id().call().await.unwrap();
    assert_eq!(result.value, c);
}

#[tokio::test]
async fn can_get_code_size() {
    let (instance, _id) = get_call_frames_instance().await;
    let result = instance.get_code_size().call().await.unwrap();
    assert!(is_within_range(result.value));
}

#[tokio::test]
async fn can_get_first_param() {
    let (instance, _id) = get_call_frames_instance().await;
    let result = instance.get_first_param().call().await.unwrap();
    assert!(is_within_range(result.value));
}

#[tokio::test]
async fn can_get_second_param() {
    let (instance, _id) = get_call_frames_instance().await;
    let result = instance.get_second_param().call().await.unwrap();
    assert!(is_within_range(result.value));
}

fn is_within_range(n: u64) -> bool {
    if n <= 0 || n > VM_MAX_RAM {
        false
    } else {
        true
    }
}
