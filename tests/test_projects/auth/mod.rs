use fuel_tx::Salt;
use fuels_abigen_macro::abigen;
use fuels_contract::contract::Contract;
use rand::rngs::StdRng;
use rand::{Rng, SeedableRng};


#[tokio::test]
async fn is_external() {
    abigen!(AuthContract, "test_artifacts/auth_testing_contract/src/abi.json");
    let salt = new_salt();
    let compiled = Contract::compile_sway_contract("test_artifacts/auth_testing_contract", salt).unwrap();
    let (client, _auth_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let auth_instance = AuthContract::new(compiled, client);


    let result = auth_instance
        .is_caller_external(true)
        .call()
        .await
        .unwrap();

        assert_eq!(result.value, false);
}

#[tokio::test]
async fn msg_sender_from_external() {
    abigen!(AuthContract, "test_artifacts/auth_testing_contract/src/abi.json");
    let salt = new_salt();
    let compiled = Contract::compile_sway_contract("test_artifacts/auth_testing_contract", salt).unwrap();
    let (client, _auth_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let auth_instance = AuthContract::new(compiled, client);

    let zero_id = authcontract_mod::ContractId {
        value: [0u8; 32],
    };

    let result = auth_instance
        .returns_msg_sender(true)
        .call()
        .await
        .unwrap();

        assert_eq!(result.value, zero_id);
}

#[tokio::test]
async fn msg_sender_from_internal() {
    // need to deploy 2 contracts !
    abigen!(AuthCallerContract, "test_artifacts/auth_caller_contract/src/abi.json");
    let salt = new_salt();
    let compiled = Contract::compile_sway_contract("test_artifacts/auth_caller_contract", salt).unwrap();
    let (client, auth_caller_id) = Contract::launch_and_deploy(&compiled).await.unwrap();
    let auth_caller_instance = AuthCallerContract::new(compiled, client);

    let compiled_2 = Contract::compile_sway_contract("test_artifacts/auth_testing_contract", salt).unwrap();
    let (client, _auth_id) = Contract::launch_and_deploy(&compiled_2).await.unwrap();


    let zero_id = authcallercontract_mod::ContractId {
        value: auth_caller_id.into(),
    };

    let sway_id= authcallercontract_mod::ContractId {
        value: auth_caller_id.into(),
    };

    let result = auth_caller_instance
        .call_auth_contract(true)
        .call()
        .await
        .unwrap();

        assert_eq!(result.value, sway_id);
}

fn new_salt() -> Salt {
    let rng = &mut StdRng::seed_from_u64(2321u64);
    let salt: [u8; 32] = rng.gen();
    let salt = Salt::from(salt);
    salt
}
