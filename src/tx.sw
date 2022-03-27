//! Transaction field getters.
//! This will be replaced by instructions: https://github.com/FuelLabs/fuel-specs/issues/287
library tx;

use ::address::Address;
use ::contract_id::ContractId;

////////////////////////////////////////
// Transaction fields
////////////////////////////////////////

// The transaction starts at
// TX_START = 32 + MAX_INPUTS*(32+8) + 8 = 32 + 255 * (40) + 8 = 10240
//
// Note that everything when serialized is padded to word length.
//
// type             = TX_START +  0*WORD_SIZE = 10240 +  0*8 = 10240
// gasPrice         = TX_START +  1*WORD_SIZE = 10240 +  1*8 = 10248
// gasLimit         = TX_START +  2*WORD_SIZE = 10240 +  2*8 = 10256
// bytePrice        = TX_START +  3*WORD_SIZE = 10240 +  3*8 = 10264
// maturity         = TX_START +  4*WORD_SIZE = 10240 +  4*8 = 10272
// scriptLength     = TX_START +  5*WORD_SIZE = 10240 +  5*8 = 10280
// scriptDataLength = TX_START +  6*WORD_SIZE = 10240 +  6*8 = 10288
// inputsCount      = TX_START +  7*WORD_SIZE = 10240 +  7*8 = 10296
// outputsCount     = TX_START +  8*WORD_SIZE = 10240 +  8*8 = 10304
// witnessesCount   = TX_START +  9*WORD_SIZE = 10240 +  9*8 = 10312
// receiptsRoot     = TX_START + 10*WORD_SIZE = 10240 + 10*8 = 10320
// script start     = TX_START + 11*WORD_SIZE = 10240 + 11*8 = 10328

const TX_TYPE_OFFSET = 10240;
const TX_GAS_PRICE_OFFSET = 10248;
const TX_GAS_LIMIT_OFFSET = 10256;
const TX_BYTE_PRICE_OFFSET = 10264;
const TX_MATURITY_OFFSET = 10272;
const TX_SCRIPT_LENGTH_OFFSET = 10280;
const TX_SCRIPT_DATA_LENGTH_OFFSET = 10288;
const TX_INPUTS_COUNT_OFFSET = 10296;
const TX_OUTPUTS_COUNT_OFFSET = 10304;
const TX_WITNESSES_COUNT_OFFSET = 10312;
const TX_RECEIPTS_ROOT_OFFSET = 10320;
const TX_SCRIPT_START_OFFSET = 10328;

/// Get the transaction type.
pub fn tx_type() -> u8 {
    asm(r1, r2: TX_TYPE_OFFSET) {
        lw r1 r2 i0;
        r1: u8
    }
}

/// Get the number of inputs.
pub fn get_inputs_count() -> u64 {
    asm(r1, r2: TX_INPUTS_COUNT_OFFSET) {
        lw r1 r2 i0;
        r1: u64
    }
}

////////////////////////////////////////
// Script
////////////////////////////////////////

// TODO some safety checks on the input data? We are going to assume it is the right type for now.
pub fn get_script_data<T>() -> T {
    asm(script_data_len, to_return, script_data_ptr, script_len, script_len_ptr: TX_SCRIPT_LENGTH_OFFSET, script_data_len_ptr: TX_SCRIPT_DATA_LENGTH_OFFSET) {
        lw script_len script_len_ptr i0;
        lw script_data_len script_data_len_ptr i0;
        // get the start of the script data
        // script_len + script_start
        add script_data_ptr script_len is;
        // allocate memory to copy script data into
        aloc script_data_len;
        move to_return sp;
        // copy script data into above buffer
        mcp to_return script_data_ptr script_data_len;
        to_return: T
    }
}

////////////////////////////////////////
// Inputs
////////////////////////////////////////

/// Get a pointer to an input given the index of the input.
pub fn get_input_pointer(index: u64) -> u32 {
    asm(r1, r2: index) {
        xis r1 r2;
        r1: u32
    }
}

/// Get the type (0|1) of an input given a pointer to the input.
pub fn get_input_type(ptr: u32) -> u8 {
    asm(r1, r2: ptr) {
        lw r1 r2 i0;
        r1: u8
    }
}

/// If the input's type is `InputCoin`, return the owner.
/// Otherwise, undefined behavior.
pub fn get_input_owner(input_ptr: u32) -> Address {
    let owner_addr = ~Address::from(asm(buffer, ptr: input_ptr) {
        // Need to skip over six words, so add 8*6=48
        addi ptr ptr i48;
        // Save old stack pointer
        move buffer sp;
        // Extend stack by 32 bytes
        cfei i32;
        // Copy 32 bytes
        mcpi buffer ptr i32;
        // `buffer` now points to the 32 bytes
        buffer: b256
    });

    owner_addr
}

////////////////////////////////////////
// Outputs
////////////////////////////////////////
