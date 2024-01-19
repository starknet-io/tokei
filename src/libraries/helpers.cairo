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

//Checks that neither fee is greater than `max_fee`, and then calculates the protocol fee amount, the
/// broker fee amount, and the deposit amount from the total amount.
fn check_and_calculate_fees(
    total_amount: u128, protocol_fee: u128, broker_fee: u128, max_fee: u128
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
    let protocol_fee = total_amount * protocol_fee;

    // Calculate the broker fee amount.
    let broker_fee = total_amount * broker_fee;

    // Assert that the total amount is strictly greater than the sum of the protocol fee amount and the
    // broker fee amount.
    assert(total_amount > protocol_fee + broker_fee, TOTAL_AMOUNT_TOO_LOW);

    // Calculate the deposit amount (the amount to stream, net of fees).
    let deposit = total_amount - protocol_fee - broker_fee;

    // Return the amounts.
    CreateAmounts { protocol_fee, broker_fee, deposit }
}

fn check_create_with_range(deposit_amount: u128, range: Range) {
    assert(deposit_amount > 0, DEPOSIT_AMOUNT_ZERO);
    assert(range.cliff > range.start, START_TIME_GREAT_THAN_CLIFF_TIME);
    assert(range.end > range.cliff, CLIFF_TIME_LESS_THAN_END_TIME);

    let current_time = get_block_timestamp();
    assert(current_time < range.end, CURRENT_TIME_GREATER_THAN_END_TIME)
}

