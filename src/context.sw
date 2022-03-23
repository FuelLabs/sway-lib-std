library context;
//! Functionality for accessing context-specific information about the current contract or message.

use ::contract_id::ContractId;
use ::call_frames::*;

dep context/call_frames;
dep context/registers;

/// Retrieve the balance of asset 'asset_id' for the contract at 'contract_id'.
pub fn balance(asset_id: ContractId, target: ContractId) -> u64 {
    asm(balance, token: asset_id.value, id: target.value) {
        bal balance token id;
        balance: u64
    }
}

/// Get the balance of coin `asset_id` for the current contract.
pub fn this_balance(asset_id: ContractId) -> u64 {
    balance(asset_id, contract_id())
}

/// Get the balance of coin `asset_id` for any contract `ctr_id`.
pub fn balance_of_contract(asset_id: ContractId, target: ContractId) -> u64 {
    balance(asset_id, target)
}

/// Get the amount of units of `msg_asset_id()` being sent.
pub fn msg_amount() -> u64 {
    asm() {
        bal: u64
    }
}

/// Get the remaining gas in the context.
pub fn gas() -> u64 {
    asm() {
        cgas: u64
    }
}

/// Get the remaining gas globally.
pub fn global_gas() -> u64 {
    asm() {
        ggas: u64
    }
}
