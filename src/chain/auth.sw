library auth;

use ::contract_id::ContractId;
use ::address::Address;
use ::ecr::ec_recover_address;
use ::result::*;
use ::b512::B512;


// this can be a generic option when options land
pub enum Caller {
    Some: b256,
    None: (),
}

impl core::ops::Ord for Caller {
    fn gt(self, other: Self) -> bool {
        asm(r1: self, r2: other, r3) {
            gt r3 r1 r2;
            r3: bool
        }
    }
    fn lt(self, other: Self) -> bool {
        asm(r1: self, r2: other, r3) {
            lt r3 r1 r2;
            r3: bool
        }
    }
    fn eq(self, other: Self) -> bool {
        asm(r1: self, r2: other, r3) {
            eq r3 r1 r2;
            r3: bool
        }
    }
}

// NOTES
// 1.) expose a msg_sender() func
// branch based on parent context
// if internal, use get_caller (wrapper for `gm r1 i2`)
// if external:
//   use get_coin_owner (should be a feature users can optionally use)

// 2.) expose a verify_signature() function
// check that caller (parent context) is external
// perform signature verification on (nonce, selector, args...)

// interfaces:
// pub fn is_caller_external() -> bool;
// pub fn fn get_caller() -> Caller;
// pub fn msg_sender() -> Caller (Option);
// pub fn get_coins_owner() -> Result<Address, AuthError>;
// pub fn get_signer(signature: B512, msg_hash: b256) -> Result<Address, AuthError>




/// Returns `true` if the caller is external (ie: a script or predicate).
pub fn caller_is_external() -> bool {
    asm(r1) {
        gm r1 i1;
        r1: bool
    }
}

// TODO: refactor to use `Result` as a return type when it lands.
pub fn msg_sender() -> Caller {
    if caller_is_external() {
        let address = get_coins_owner();
        if !(address == ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000)) {
            Caller::Some(address.value)
        } else {
            Caller::None
        }
    } else {
        // Get caller's contract ID
        Caller::Some(asm(r1) {
            gm r1 i2;
            r1: b256
        })
    }
}

// temp
pub fn get_coins_owner() -> Address {
  ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000)
}

// fn get_coins_owner() -> Address {
//     let inputs: Input[] = ?;
//     let owner_candidate: b256 = 0;
//     let  mut i = 0;
//     let mut input: Input;
//     // let len =
//     while i < inputs.length {
//         input = inputs[i];
//         if input.type = Coin {
//             if candidate = zero {
//                 candidate = coin.owner;
//             } else {
//                 if coin.owner == candidate {
//                     continue;
//                 } else {
//                     return Caller::None
//                }
//             }
//         }
//         i ++;
//     }
//     Caller::Some(owner_candidate)
// }

enum AuthError {
    InvalidContext : (),
}

// TODO use `Result` as the return type when it lands.
/// A wrapper for ec-recover_address which is aware of the parent context and returns the appropriate result accordingly.
pub fn get_signer(signature: B512, msg_hash: b256) -> Address {
    if !caller_is_external() {
        ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000)
    } else {
        ec_recover_address(signature, msg_hash)
    }
}
