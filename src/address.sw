library address;
//! A wrapper around the b256 type to help enhance type-safety.

/// The Address type, a struct wrappper around the inner `value`.
pub struct Address {
    value: b256,
}

impl core::ops::Ord for Address {
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

// TODO make this generic when possible.
pub trait From {
    fn from(b: b256) -> Self;
} {
    fn into(addr: Address) -> b256 {
        addr.value
    }
}

/// Functions for casting between the b256 and Address types.
impl From for Address {
    fn from(bits: b256) -> Address {
        Address {
            value: bits,
        }
    }
}
