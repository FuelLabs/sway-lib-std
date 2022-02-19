library auth;

use ::contract_id::ContractId;
use ::address::Address;
use ::ecr::ec_recover_address;
use ::result::*;
use ::b512::B512;


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
