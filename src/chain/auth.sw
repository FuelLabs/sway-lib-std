library auth;

use ::contract_id::ContractId;


// this can be a generic option when options land
pub enum Caller {
    Some: ContractId,
    None: (),
}

// temp! delete and use core::ops when possible.
pub trait Ord {
    fn gt(self, other: Self) -> bool;
    fn lt(self, other: Self) -> bool;
    fn eq(self, other: Self) -> bool;
} {
    fn le(self, other: Self) -> bool {
        self.lt(other) || self.eq(other)
    }
    fn ge(self, other: Self) -> bool {
        self.gt(other) || self.eq(other)
    }
    fn neq(self, other: Self) -> bool {
        // TODO unary operator negation
        if self.eq(other) {
            false
        } else {
            true
        }
    }
}

impl Ord for Caller {
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

// temp

// I propose a standard library module to perform authentication in three ways:

//     1.)Contract caller. This is as simple as checking that the parent context is not external, then fetching the parent context's contract ID.

//     2.)Signature. Check that the parent context is external, then perform signature verification on (nonce, selector, args...), where nonce is the nonce of the user signing the action. This nonce is stored in the contract's storage, as opposed to Ethereum where nonces are associated with accounts globally.

//     3.)All-the-same. Check that the parent context is external, then check that all non-contract inputs are all owned by the same address (which could be a predicate hash or a pubkey hash). If so, then consider that address as the caller. This is a heuristic that does not work in all cases, so should be a feature users can optionally use.

// use only if needed
// pub fn context_is_external() -> bool {
//     asm(rslt) {
//         eq rslt fp zero;
//         rslt: bool
//     }
// }

/// Returns `true` if the caller is external (ie: a script or predicate).
pub fn is_caller_external() -> bool {
    asm(r1) {
        gm r1 i1;
        r1: bool
    }
}

pub fn get_caller() -> Caller {
    if !is_caller_external() {
        // get the caller
        Caller::Some(~ContractId::from(asm(r1) {
            gm r1 i2;
            r1: b256
        }))
    } else {
        Caller::None
    }
}

// pub fn caller() -> Caller {
//     Caller::Some(asm(r1) {
//         gmr1i2;
//         r1: b256
//     })
// }

// @note there's currently nothing to stop someone from calling this function in a script (I'm not sure that it would make sense to do so though...), where caller_is_external will always panic.
// Consider using context_is_external() as an aditional check to make this more robust
pub fn msg_sender() -> Caller {
    // called by scripts or predicates
    if is_caller_external() {
        get_coin_owner() // calls from other contracts or addresses
    } else {
        get_caller()
    }
}

// temp
fn get_coin_owner() -> Caller {
    Caller::Some(~ContractId::from(0x0000000000000000000000000000000000000000000000000000000000000000))
}

// fn get_coin_owner() -> b256 {
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
