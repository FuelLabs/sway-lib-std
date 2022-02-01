library reentrancy;

use ::context::contract_id;
use ::auth::caller_is_external;

pub fn is_reentrant() -> bool {
    let mut reentrant = false;
    // is_reentrant function that loops over the contract ID of each parent call frame and compares it against the current contract ID."
    // get parent's id
    let initial_parent_id = contract_id();
    let mut is_external = caller_is_external();
    let i = 0u64;

    while !is_external {
        get_parent_call_frame(); // ?
        new_parent_id = contract_id();
        if new_parent_id == initial_parent_id {
          reentrant = true;
          is_external = true; // invalidate the condition to break the while loop
        } else {
          // check if we've reached an external context yet
          is_external = caller_is_external()
          i = i + 1; // increment the index
        }
    }
    /// go back up the call stack until we reach an external context. Compare each parents' contract id with initial_parent_id. A match mean s reentrancy!
    reentrant

}