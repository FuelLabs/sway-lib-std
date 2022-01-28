//! Error handling with the `Option` type.
//!
//! [`Option<T>`][`Option`] is the type used for returning and propagating
//! errors. It is an enum with the variants, [`Some(T)`], representing
//! the existence of a value, and [`None()`], representing
//! the absence of a value.

library option;

/// `Option` is a type that represents either the existence of a value ([`Some`]) or a value's absence
/// ([`None`]).
pub enum Option<T> {
    /// Contains the value
    Some: T,

    /// Signifies the absence of a value
    None: (),
}

/////////////////////////////////////////////////////////////////////////////
// Type implementation
/////////////////////////////////////////////////////////////////////////////

impl Option<T> {
    /////////////////////////////////////////////////////////////////////////
    // Querying the contained values
    /////////////////////////////////////////////////////////////////////////

    /// Returns `true` if the result is [`Some`].
    fn is_some(self) -> bool {
        match self {
            Option::Some(T) => {
                true
            },
            _ => {
                false
            },
        }
    }

    /// Returns `true` if the result is [`None`].
    fn is_none(self) -> bool {
        match self {
            Option::Some() => {
                false
            },
            _ => {
                true
            },
        }
    }
}
