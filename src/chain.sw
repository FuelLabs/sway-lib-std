library chain;
dep chain/auth;

use ::panic::panic;

// When generics land, these will be generic.
pub fn log_u64(val: u64) {
    asm(r1: val) {
        log r1 zero zero zero;
    }
}

pub fn log_u32(val: u32) {
    asm(r1: val) {
        log r1 zero zero zero;
    }
}

pub fn log_u16(val: u16) {
    asm(r1: val) {
        log r1 zero zero zero;
    }
}

pub fn log_u8(val: u8) {
    asm(r1: val) {
        log r1 zero zero zero;
    }
}

// The transaction starts at:
// 32 + MAX_INPUTS*(32+8) + 8.
// Everything when serialized is padded to word length, so if there are 4 fields preceding script data then it's 4 words.
//
// start: SCRIPT_LENGTH + SCRIPT_START
// end:   start + SCRIPT_DATA_LEN
// where:
// SCRIPT_DATA_LEN = mem[TX_START + 4 words, 32 bytes)         // 10240 + 32          = 10272
// SCRIPT_LENGTH   = mem[TX_START + 3 words, 24 bytes] as u16  // 10240 + 24          = 10264
// TX_START        = 32 + MAX_INPUTS * (32 + 8) + 8            // 32 + 255 * (40) + 8 = 10240
// MAX_INPUTS      = 255
// SCRIPT_START    = $is

// TODO some safety checks on the input data? We are going to assume it is the right type for now.
pub fn get_script_data<T>() -> T {
    asm(script_data_len, to_return, script_data_ptr, script_len, script_len_ptr: 10264, script_data_len_ptr: 10272) {
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
