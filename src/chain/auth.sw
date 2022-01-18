library auth;

// this can be a generic option when options land
pub enum Caller {
  Some: b256,
  None: (),
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

// use only if needed
// pub fn context_is_external() -> bool {
//     asm(rslt) {
//         eq rslt fp zero;
//         rslt: bool
//     }
// }

/// Returns `true` if the caller is external.
pub fn caller_is_external() -> bool {
  asm(r1) {
    gm r1 i1;
    r1: bool
  }
}

pub fn caller() -> Caller {
    Caller::Some(asm(r1) {
      gm r1 i2;
      r1: b256
    })
}

// @note there's currently nothing to stop someone from calling this function in a script (I'm not sure that it would make sense to do so though...), where caller_is_external will always panic.
// Consider using context_is_external() as an aditional check to make this more robust
pub fn msg_sender() -> Caller {
    // called by scripts or predicates
    if caller_is_external() {
        get_coin_owner()
    // calls from other contracts or addresses
    } else {
        caller()
    }
}

// temp
fn get_coin_owner() -> Caller {
    Caller::Some(0x0000000000000000000000000000000000000000000000000000000000000000)
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


// TODO some safety checks on the input data? We are going to assume it is the right type for now.
// TODO make this generic
// @todo extract this into its own lib?

// pub fn get_script_data() -> u64 {
//     asm(script_data_len, to_return, script_data_ptr, script_len, script_len_ptr: 376, script_data_len_ptr: 384) {
//         lw script_len script_len_ptr;
//         lw script_data_len script_data_len_ptr;
//         // get the start of the script data
//         // script_len + script_start
//         add script_data_ptr script_len is;
//         // allocate memory to copy script data into
//         mv to_return sp;
//         cfe script_data_len;
//         // copy script data into above buffer
//         mcp to_return script_data_ptr script_data_len;
//         to_return: u64 // should be T when generic
//     }
// }
