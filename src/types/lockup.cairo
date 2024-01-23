// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::{TryInto, Into};
use zeroable::Zeroable;
use debug::PrintTrait;
use tokei::types::lockup_linear::{Range, Broker, LockupLinearStream};

/// Represent Lockup amounts.
// Struct encapsulating the deposit, withdrawn, and refunded amounts, all denoted in units
/// of the asset's decimals.
#[derive(Drop, Copy, starknet::Store, Serde, PartialEq)]
struct LockupAmounts {
    /// The initial amount deposited in the stream, net of fees.
    deposited: u256,
    /// The cumulative amount withdrawn from the stream.
    withdrawn: u256,
    /// The amount refunded to the sender. Unless the stream was canceled, this is always zero.
    refunded: u256,
}

/// Represent Create amounts.
/// Struct encapsulating the deposit amount, the protocol fee amount, and the broker fee amount,
/// all denoted in units of the asset's decimals.
#[derive(Drop, Copy, starknet::Store, Serde, PartialEq)]
struct CreateAmounts {
    /// The amount to deposit in the stream.
    deposit: u256,
    /// The protocol fee amount.
    protocol_fee: u256,
    /// The broker fee amount.
    broker_fee: u256,
}

/// Represent Stream status.
/// Enum representing the status of a stream.
#[derive(Serde, Copy, Drop, starknet::Store, PartialEq)]
enum Status {
    PENDING,
    STREAMING,
    SETTLED,
    CANCELED,
    DEPLETED,
}

/// Represent Status into felt252.
impl StatusIntoFelt252 of Into<Status, felt252> {
    fn into(self: Status) -> felt252 {
        match self {
            Status::PENDING(()) => 0,
            Status::STREAMING(()) => 1,
            Status::SETTLED(()) => 2,
            Status::CANCELED(()) => 3,
            Status::DEPLETED(()) => 4
        }
    }
}

/// Implementation of `Zeroable` trait for `CreateAmounts`.
impl CreateAmountsZeroable of Zeroable<CreateAmounts> {
    fn zero() -> CreateAmounts {
        CreateAmounts { deposit: 0, protocol_fee: 0, broker_fee: 0, }
    }
    #[inline(always)]
    fn is_zero(self: CreateAmounts) -> bool {
        self.deposit.is_zero() && self.protocol_fee.is_zero() && self.broker_fee.is_zero()
    }
    #[inline(always)]
    fn is_non_zero(self: CreateAmounts) -> bool {
        !self.is_zero()
    }
}

/// Implementation of `PrintTrait` trait for `CreateAmounts`.
impl CreateAmountsPrintTrait of PrintTrait<CreateAmounts> {
    fn print(self: CreateAmounts) {
        let message = array![
            'CreateAmounts: ', self.deposit.into(), self.protocol_fee.into(), self.broker_fee.into()
        ];
    // message.print();
    }
}

impl LockupLinearStreamPrintTrait of PrintTrait<LockupLinearStream> {
    fn print(self: LockupLinearStream) {
        let message = array![
            'LockupLinearStream: ',
            self.sender.into(),
            self.asset.into(),
            self.start_time.into(),
            self.cliff_time.into(),
            self.end_time.into(),
            self.is_cancelable.into(),
            self.was_canceled.into(),
            self.is_depleted.into(),
            self.is_stream.into(),
            self.is_transferable.into(),
        ];
        message.print();
    }
}
