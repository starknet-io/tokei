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

/// Represent Create amounts.
/// Struct encapsulating the deposit amount, the protocol fee amount, and the broker fee amount,
/// all denoted in units of the asset's decimals.
#[derive(Drop, Copy, starknet::Store, Serde)]
struct CreateAmounts {
    /// The amount to deposit in the stream.
    deposit: u128,
    /// The protocol fee amount.
    protocol_fee: u128,
    /// The broker fee amount.
    broker_fee: u128,
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
        message.print();
    }
}
