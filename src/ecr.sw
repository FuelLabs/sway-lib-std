library ecr;

use ::b512::B512;
use ::address::Address;

// @todo expose both a recovered address && a recovered public key for consumption

/// Recover the address derived from the private key used to sign a message
pub fn ec_recover(signature: B512, msg_hash: b256) -> Address {

    // ECR: "The 64-byte public key (x, y) recovered from 64-byte signature starting at $rB on 32-byte message hash starting at $rC"
    // s256: The sha-256 hash of $rC bytes starting at $rB.
    let address = asm(pub_key_buffer, sig_ptr: signature.hi, hash: msg_hash, addr_buffer, sixty_four: 64) {
        move pub_key_buffer sp; // mv sp to pub_key result buffer.
        cfei i64;
        ecr pub_key_buffer sig_ptr hash; // recover public_key from sig & hash
        move addr_buffer sp; // mv sp to addr result buffer.
        cfei i32;
        s256 addr_buffer pub_key_buffer sixty_four; // hash 64 bytes to the addr_buffer
        addr_buffer: b256
    };

    ~Address::from(address)
}

/// Recover the public key derived from the private key used to sign a message
pub fn recover_pubkey(signature: B512, msg_hash: b256) -> B512 {
    let pub_key_hi = asm(buffer, hi: signature.hi, hash: msg_hash) {
        move buffer sp; // Result buffer.
        cfei i32;
        ecr buffer hi hash;
        buffer: b256
    };

    let pub_key_lo = asm(buffer, hi_ptr: pub_key_hi, lo) {
        move buffer sp;
        cfei i32;
        addi lo hi_ptr i32;
        mcpi buffer lo i32;
        buffer: b256
    };

    ~B512::from(pub_key_hi, pub_key_lo)
}
