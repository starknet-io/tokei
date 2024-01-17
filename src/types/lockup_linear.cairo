// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::{TryInto, Into};
use starknet::ContractAddress;

// Local imports.
use tokei::types::lockup::LockupAmounts;

/// Represent a Lockup Linear Stream.
#[derive(Drop, starknet::Store, Serde)]
struct LockupLinearStream {
    /// The address streaming the assets, with the ability to cancel the stream.
    sender: ContractAddress,
    /// The contract address of the ERC-20 asset used for streaming.
    asset: ContractAddress,
    /// The Unix timestamp indicating the stream's start.
    start_time: u64,
    /// The Unix timestamp indicating the stream's end.
    end_time: u64,
    /// Boolean indicating if the stream is cancelable.
    is_cancelable: bool,
    /// Boolean indicating if the stream was canceled.
    was_canceled: bool,
    /// Boolean indicating if the stream is depleted.
    is_depleted: bool,
    /// Boolean indicating if its a stream.
    is_stream: bool,
    /// Boolean indicating if the stream is transferable.
    is_transferable: bool,
    /// Struct containing the deposit, withdrawn, and refunded amounts, all denoted in units of the
    /// asset's decimals.
    amounts: LockupAmounts,
}

/// Represents a time range for linear lockups.
#[derive(Drop, starknet::Store, Serde)]
struct Range {
    /// The timestamp for the stream's start.
    start: u64,
    /// The timestamp for the cliff period's end.
    cliff: u64,
    /// The timestamp for the stream's end.
    end: u64,
}

/// Represents the broker parameters passed to the create functions. Both can be set to zero.
#[derive(Drop, starknet::Store, Serde)]
struct Broker {
    /// The address receiving the broker's fee.
    account: ContractAddress,
    /// The broker's percentage fee from the total amount.
    fee: u128,
}

/// Represents the durations for the cliff and total periods.
#[derive(Drop, starknet::Store, Serde)]
struct Durations {
    /// The duration of the cliff period.
    cliff: u64,
    /// The total duration of the stream.
    total: u64,
}
