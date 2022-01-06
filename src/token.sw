library token;
//! Functionality for performing common operations on tokens.

use ::address::Address;
use ::contract_id::ContractId;
use ::chain::panic;

// note: if tx format changes, the magic number "48" must be changed !
/// TransactionScript outputsCount has a 48 byte(6 words * 8) offset
/// Transaction Script: https://github.com/FuelLabs/fuel-specs/blob/master/specs/protocol/tx_format.md#transactionscript
/// Output types: https://github.com/FuelLabs/fuel-specs/blob/master/specs/protocol/tx_format.md#output
const OUTPUT_LENGTH_LOCATION = 48;
const OUTPUT_VARIABLE_TYPE = 4;

/// Mint `amount` coins of the current contract's `asset_id`.
pub fn mint(amount: u64) {
    asm(r1: amount) {
        mint r1;
    }
}

/// Burn `amount` coins of the current contract's `asset_id`.
pub fn burn(amount: u64) {
    asm(r1: amount) {
        burn r1;
    }
}

/// Transfer `amount` coins of type `asset_id` to address `recipient`.
pub fn transfer_to_output(amount: u64, asset_id: ContractId, recipient: Address) {
    // get length of outputs from TransactionScript outputsCount:
    let length: u8 = asm(outputs_length, outputs_length_ptr: OUTPUT_LENGTH_LOCATION) {
        lw outputs_length outputs_length_ptr i0;
        outputs_length: u8
    };
    // maintain a manual index as we only have `while` loops in sway atm:
    let mut index: u8 = 0;
    let mut outputIndex = 0;
    let mut output_found = false;

    // If an output of type `OutputVariable` is found, check if its `amount` is zero.
    // As one cannot transfer zero coins to an output without a panic, a variable output with a value of zero is by definition unused.
    while index < length {
        let target_output_type_exists = asm(slot: index, type, target: OUTPUT_VARIABLE_TYPE, bytes: 8, res) {
            xos type slot;
            meq res type target bytes;
            res: bool
        };
        // if an ouput is found of type `OutputVariable`:
        if target_output_type_exists {
            let amount_is_zero = asm(slot: index, a, amount_ptr, output, is_zero, bytes: 8) {
                xos output slot;
                addi amount_ptr output i64;
                lw a amount_ptr i0;
                meq is_zero a zero bytes;
                is_zero: bool
            };
            // && if the amount is zero:
            if amount_is_zero {
                // then store the index of the output and record the fact that we found a suitable output.
                outputIndex = index;
                output_found = true;
                // todo: use "break" keyword when it lands.
                index = length; // break early and use the output we found
            } else {
                // otherwise, increment the index and continue the loop.
                index = index + 1;
            }
        }
    }
    // If no suitable output was found, revert.
    if output_found {
        asm(amnt: amount, id: asset_id.value, recipient, output: index) {
            tro recipient output amnt id;
        }
    } else {
        panic(0)
    }
}

/// !!! UNCONDITIONAL transfer of `amount` coins of type `asset_id` to contract at `contract_id`.
/// This will allow the transfer of coins even if there is no way to retrieve them !!!
/// Use of this function can lead to irretrievable loss of coins if not used with caution.
pub fn force_transfer(amount: u64, asset_id: ContractId, contract_id: ContractId) {
    asm(r1: amount, r2: asset_id.value, r3: contract_id.value) {
        tr r3 r1 r2;
    }
}
