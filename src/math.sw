library math;

pub trait Square {
    fn sqrt(self) -> Self;
}

impl Square for u64 {
    fn sqrt(self) -> Self {
        let square: u64 = 2;
        asm(r1: self, r2: square, r3) {
            mroo r3 r1 r2;
            r3: u64
        }
    }
}

impl Square for u32 {
    fn sqrt(self) -> Self {
        let square: u32 = 2;
        asm(r1: self, r2: square, r3) {
            mroo r3 r1 r2;
            r3: u32
        }
    }
}

impl Square for u16 {
    fn sqrt(self) -> Self {
        let square: u16 = 2;
        asm(r1: self, r2: square, r3) {
            mroo r3 r1 r2;
            r3: u16
        }
    }
}

impl Square for u8 {
    fn sqrt(self) -> Self {
        let square: u8 = 2;
        asm(r1: self, r2: square, r3) {
            mroo r3 r1 r2;
            r3: u8
        }
    }
}
