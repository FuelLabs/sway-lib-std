//! Error handling with the `Option` type.
//!
//! [`Option<T>`][`Option`] is the type used for representing the existence or absence of a value. It is an enum with the variants, [`Some(T)`], representing
//! some value, and [`None()`], representing
//! no value.

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
}

/////////////////////////////////////////////////////////////////////////
// Querying the contained values
/////////////////////////////////////////////////////////////////////////

/// Returns `true` if the result is [`Some`].
pub fn option_is_some(o: Option) -> bool {
    if let Option::Some(t) = o {
        true
    } else {
        false
    }
}

/// Returns `true` if the result is [`None`].
pub fn option_is_none(o: Option) -> bool {
    if let Option::Some(t) = o {
        false
    } else {
        true
    }
}
