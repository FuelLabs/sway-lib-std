library math;

// Technically this isn't Square in the mathematical sense
// but there wasn't another good name for this trait
pub trait Square {
    fn sqrt(self, other: Self) -> Self;
}

impl Square for u64 {
    fn sqrt(self, other: Self) -> Self {
        asm(r1: self, r2: other, r3) {
            sqrt r3 r2 r1;
            r3: u64
        }
    }
}

impl Square for u32 {
    fn sqrt(self, other: Self) -> Self {
        asm(r1: self, r2: other, r3) {
            sqrt r3 r2 r1;
            r3: u32
        }
    }
}

impl Square for u16 {
    fn sqrt(self, other: Self) -> Self {
        asm(r1: self, r2: other, r3) {
            sqrt r3 r2 r1;
            r3: u16
        }
    }
}

impl Square for u8 {
    fn sqrt(self, other: Self) -> Self {
        asm(r1: self, r2: other, r3) {
            sqrt r3 r2 r1;
            r3: u8
        }
    }
}
