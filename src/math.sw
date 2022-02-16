library math;

// Technically this isn't Square in the mathematical sense
// but there wasn't another good name for this trait
pub trait Square {
    fn sqrt(self) -> Self;
}

impl Square for u64 {
    fn sqrt(self) -> Self {
        let square:u64 = 2;
        asm(r1: self, r2: square, r3) {
            mroo r3 r2 r2;
            r3: u64
        }
    }
}

