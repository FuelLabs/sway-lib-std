library ecr;

use ::address::Address;
use ::b512::B512;
use ::hash::{HashMethod, hash_pair};

/// Recover the public key derived from the secret key used to sign a message.
/// Panics if a public key cannot be recovered.
pub fn ec_recover(signature: B512, msg_hash: b256) -> B512 {
    let public_key = ~B512::new();

    asm(buffer: public_key.bytes, sig: signature.bytes, hash: msg_hash) {
        ecr buffer sig hash;
    };

    public_key
}

/// Recover the address derived from the secret key used to sign a message
pub fn ec_recover_address(signature: B512, msg_hash: b256) -> Address {
    let public_key = ec_recover(signature, msg_hash);
    let address = hash_pair(public_key.bytes[0], public_key.bytes[1], HashMethod.Sha256);
    ~Address::from(address)
}
