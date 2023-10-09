// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use zeroable::Zeroable;

// Local imports.
use tokei::types::lockup::CreateAmounts;
use tokei::libraries::errors;

//Checks that neither fee is greater than `max_fee`, and then calculates the protocol fee amount, the
/// broker fee amount, and the deposit amount from the total amount.
fn check_and_calculate_fees(
    total_amount: u128, protocol_fee: u128, broker_fee: u128, max_fee: u128
) -> CreateAmounts {
    // TODO: Handle fixed point arithmetic everywhere.

    // When the total amount is zero, the fees are also zero.
    if (total_amount.is_zero()) {
        return Zeroable::zero();
    }

    // Checks: the protocol fee is not greater than `max_fee`.
    if (protocol_fee > max_fee) {
        errors::Lockup::protocol_fee_too_high(protocol_fee, max_fee);
    }

    // Checks: the broker fee is not greater than `max_fee`.
    if (broker_fee > max_fee) {
        errors::Lockup::broker_fee_too_high(broker_fee, max_fee);
    }

    // Calculate the protocol fee amount.
    let protocol_fee = total_amount * protocol_fee;

    // Calculate the broker fee amount.
    let broker_fee = total_amount * broker_fee;

    // Assert that the total amount is strictly greater than the sum of the protocol fee amount and the
    // broker fee amount.
    assert(total_amount > protocol_fee + broker_fee, 'total_amount_too_low');

    // Calculate the deposit amount (the amount to stream, net of fees).
    let deposit = total_amount - protocol_fee - broker_fee;

    // Return the amounts.
    CreateAmounts { protocol_fee, broker_fee, deposit }
}
