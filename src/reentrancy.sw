library reentrancy;

use ::context::contract_id;
use ::auth::caller_is_external;
// You can use the saved $fp of the previous call frame to tell you where the previous call frame begins. The saved $fp is at a fixed offset from the start of each call frame.

/*
While the context == internal:
  get current call frame with $fp
  get saved registers from previous context ($fp + 64)
  get the saved ContractId (48-byte offset from start of saved registers)
    if this is the first iteration:
      save the ContractID
    else:
      compare to saved ContractId
      if Id == savedId
        reentrancy = true
      else
        continue

*/


pub fn is_reentrant() -> bool {
    let mut reentrancy = false;
    let mut internal = !caller_is_external();

    // let current_call_frame_ptr = asm() {
    //     fp: u32
    // }

    // let previous_frame_ptr = get_parent_call_frame();

    // get the ContractId of the previous caller
    // let initial_caller_id = get_caller_id(previous_frame_ptr);

    while internal {
        let current_call_frame_ptr = get_frame_pointer()
        let previous_call_frame_ptr = get_previous_call_frame(current_call_frame_ptr)
        let parent_contract_id = get_parent_id(previous_call_frame_ptr);

        if parent_contract_id == initial_caller_id {
            reentrancy = true;
            internal = false;
        } else {
            // check if we've left the internal context yet
            internal = !caller_is_external();
        }
    }
    reentrancy
}
// the saved $fp
const CALL_FRAME_OFFSET = 48;     // 6 words * 8 bytes
const SAVED_REGISTERS_OFFSET = 16; // 2 words * 8 bytes

// if 'offset' is 0, this will get current frame. for the previous frame, 'offset' should be:
// 8*4(to) + 8*4(asset_id) = 64 (to get saved registers.)
// then, from start of saved registers, 8*6 words = 48
fn get_frame_pointer() -> u64 {
    fp: u64
}

fn get_saved_registers_location(location, offset: SAVED_REGISTERS_OFFSET) -> u64 {
    add location fp offset;
    location: u64
}

fn get_previous_caller_id(ptr: u64) -> ContractId {
    asm(id, offset: SAVED_REGISTERS_OFFSET) {
        add id fp offset;
        id: ContractId
    }
}



// pub fn is_reentrant() -> bool {
//     // current contract id = constract_id();
//     // Memory address of beginning of current call frame = $fp
//     // saved $fp is at a fixed offset from the start of each call frame.

//     // $fp points to start of current call frame's first word (contract_id)

//     // 3rd word ($fp + 2 word offset) is the saved registers from previous context. $fp + 0 in saved regs is previous contract_id, $fp + 2 words is the previous regs
//     //


//     let mut reentrant = false;
//     // is_reentrant function that loops over the contract ID of each parent call frame and compares it against the current contract ID."
//     // get parent's id
//     // let initial_parent_id = contract_id();
//     let mut is_external = caller_is_external();
//     let i = 0u64;

//     // as long as the context is internal
//     while !is_external {
//         get_parent_call_frame();
//         new_parent_id = contract_id();
//         if new_parent_id == initial_parent_id {
//           reentrant = true;
//           is_external = true; // invalidate the condition to break the while loop
//         } else {
//           // check if we've reached an external context yet
//           is_external = caller_is_external()
//           i = i + 1; // increment the index
//         }
//     }
//     /// go back up the call stack until we reach an external context. Compare each parents' contract id with initial_parent_id. A match means reentrancy!
//     reentrant
// }
