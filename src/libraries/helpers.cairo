use core::debug::PrintTrait;
// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use zeroable::Zeroable;
use starknet::get_block_timestamp;
// Local imports.
use tokei::types::lockup::CreateAmounts;
use tokei::types::lockup_linear::Range;
use tokei::libraries::errors::Lockup::{
    DEPOSIT_AMOUNT_ZERO, BROKER_FEE_TOO_HIGH, PROTOCOL_FEE_TOO_HIGH, TOTAL_AMOUNT_TOO_LOW,
    START_TIME_GREAT_THAN_CLIFF_TIME, CLIFF_TIME_LESS_THAN_END_TIME,
    CURRENT_TIME_GREATER_THAN_END_TIME
};

const BPS: u256 = 10_000; // 100% = 10_000 bps

trait PercentageMath {
    fn percent_mul(self: u256, other: u256) -> u256;
}

impl PercentageMathImpl of PercentageMath {
    fn percent_mul(self: u256, other: u256) -> u256 {
        self * other / BPS
    }
}

fn scaled_down_div(lhs: u64, rhs: u64) -> u64 {
    let SCALE_FACTOR = 100;
    let scaling_val = lhs * SCALE_FACTOR;

    let half_b = rhs / 2_u64;

    let scaled_a_rounded = scaling_val + half_b;

    let res = scaled_a_rounded / rhs;

    // let res = U64DivRem(a, b, c, Rounding::Up);

    res
}

//Checks that neither fee is greater than `max_fee`, and then calculates the protocol fee amount, the
/// broker fee amount, and the deposit amount from the total amount.
fn check_and_calculate_fees(
    total_amount: u256, protocol_fee: u256, broker_fee: u256, max_fee: u256
) -> CreateAmounts {
    // TODO: Handle fixed point arithmetic everywhere.

    // When the total amount is zero, the fees are also zero.
    if (total_amount.is_zero()) {
        return CreateAmounts { protocol_fee: 0, broker_fee: 0, deposit: 0 };
    }

    // Checks: the protocol fee is not greater than `max_fee`.
    // if (protocol_fee > max_fee) {
    //     errors::Lockup::protocol_fee_too_high(protocol_fee, max_fee);
    // }
    assert(protocol_fee < max_fee, PROTOCOL_FEE_TOO_HIGH);

    // Checks: the broker fee is not greater than `max_fee`.
    // if (broker_fee > max_fee) {
    //     errors::Lockup::broker_fee_too_high(broker_fee, max_fee);
    // }
    assert(broker_fee < max_fee, BROKER_FEE_TOO_HIGH);

    // Calculate the protocol fee amount.
    // 1 x 10^18 x 0.03 / 10000 = 3000000000000000
    let protocol_fees = total_amount.percent_mul(protocol_fee);

    // Calculate the broker fee amount.
    let broker_fees = total_amount.percent_mul(broker_fee);

    // Assert that the total amount is strictly greater than the sum of the protocol fee amount and the
    // broker fee amount.
    assert(total_amount > protocol_fees + broker_fees, TOTAL_AMOUNT_TOO_LOW);

    // Calculate the deposit amount (the amount to stream, net of fees).
    let deposit = total_amount - protocol_fees - broker_fees;

    // deposit.print();

    // Return the amounts.
    CreateAmounts { protocol_fee: protocol_fees, broker_fee: broker_fees, deposit: deposit }
}

fn check_create_with_range(deposit_amount: u256, range: Range) {
    assert(deposit_amount > 0, DEPOSIT_AMOUNT_ZERO);
    assert(range.cliff > range.start, START_TIME_GREAT_THAN_CLIFF_TIME);
    assert(range.end > range.cliff, CLIFF_TIME_LESS_THAN_END_TIME);

    let current_time = get_block_timestamp();
    assert(current_time < range.end, CURRENT_TIME_GREATER_THAN_END_TIME)
}

fn mul_div_down(lhs: u256, rhs: u256, denominator: u256) -> u256 {
    let max_u128 = integer::BoundedInt::max();
    let max_u256 = u256 { low: max_u128, high: max_u128 };
    // TODO: Change this back when u256 non-truncating division is implemented
    let cond = Zeroable::is_non_zero(denominator)
        & (Zeroable::is_zero(rhs)) | (lhs <= Div::div(max_u256, rhs));
    assert(cond, 'multiplication overflow');
    lhs * (rhs / denominator)
}
// 340282366920938463463374607431768211455
// 10040160642570281124497000000000000000000000000
// 23415782458457154298612504186280779581279436800000


