use fuel_core::service::{Config, FuelService};
use fuel_gql_client::client::FuelClient;
use fuel_tx::{Receipt, Salt, Transaction};
use fuel_types::ContractId;
use fuels_contract::script::Script;

#[tokio::test]
async fn demo_script() {
    assert_eq!(true, true);
}

#[tokio::test]
async fn script_call () {
    let fuel_client = setup_local_node();

    let compiled = Script::compile_sway_script("src/main").unwrap();

    let tx = Transaction::Script {
        gas_price: 0,
        gas_limit: 1_000_000,
        byte_price: 0,
        maturity: 0,
        receipts_root: Default::default(),
        script: compiled.raw, // Here we pass the compiled script into the transaction
        script_data: vec![],
        inputs: vec![],
        outputs: vec![],
        witnesses: vec![vec![].into()],
        metadata: None,
    };

    let script = Script::new(tx);

    let result = script.call(&fuel_client).await.unwrap();

    let expected_receipt = Receipt::Return {
        id: ContractId::new([0u8; 32]),
        val: 0,
        pc: result[0].pc().unwrap(),
        is: 464,
    };

    assert_eq!(expected_receipt, result[0]);
}


async fn setup_local_node() -> FuelClient {
    let srv = FuelService::new_node(Config::local_node()).await.unwrap();
    FuelClient::from(srv.bound_address)
}
