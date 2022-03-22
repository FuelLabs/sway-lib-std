script;

use std::chain::panic;
use std::result::*;

fn main() {
    test_ok();
    test_err();
}

fn test_ok() {
    // let r = Result::<u64, ()>::Ok(42u64);

    // if ( !result_is_ok(r) || result_is_err(r)) {
    //     panic(0);
    // }
}

fn test_err() {
    // let r = Result::<(), ()>::Err(());

    // if (result_is_ok(r) || !result_is_err(r)) {
    //     panic(0);
    // }
}
