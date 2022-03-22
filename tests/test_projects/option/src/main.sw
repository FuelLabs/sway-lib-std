script;

use std::chain::panic;
use std::option::*;

fn main() {
    test_some();
    test_none();
}

fn test_some() {
    let o = Option::Some(42u64);

    if ( !option_is_some(o) || option_is_none(o)) {
        panic(0);
    }
}

fn test_none() {
    let o = Option::None();

    if (option_is_some(o) || !option_is_none(o)) {
        panic(0);
    }
}
