// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::{TryInto, Into};

/// Represent Lockup amounts.
// Struct encapsulating the deposit, withdrawn, and refunded amounts, all denoted in units
/// of the asset's decimals.
#[derive(Drop, Copy, starknet::Store, Serde)]
struct LockupAmounts {
    /// The initial amount deposited in the stream, net of fees.
    deposited: u128,
    /// The cumulative amount withdrawn from the stream.
    withdrawn: u128,
    /// The amount refunded to the sender. Unless the stream was canceled, this is always zero.
    refunded: u128,
}
