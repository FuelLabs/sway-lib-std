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

    let script = Script::new(tx);
    let receipts = script.call(&client).await.unwrap();

    let expected_receipt = Receipt::Return {
        id: ContractId::new([0u8; 32]),
        val: 1,
        pc: receipts[0].pc().unwrap(),
        is: 464,
    };

    assert_eq!(expected_receipt, receipts[0]);
}