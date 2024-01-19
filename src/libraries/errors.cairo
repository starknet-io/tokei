mod Lockup {
    const PROTOCOL_FEE_TOO_HIGH: felt252 = 'protocol_fee_too_high';
    const BROKER_FEE_TOO_HIGH: felt252 = 'broker_fee_too_high';
    const STREAM_NOT_CANCELABLE: felt252 = 'stream_not_cancelable';
    const STREAM_CANCELED: felt252 = 'stream is canceled';
    const STREAM_SETTLED: felt252 = 'stream_settled';
    const STREAM_NOT_DEPLETED: felt252 = 'stream has not depleted';
    const STREAM_DEPLETED: felt252 = 'stream has depleted';
    const LOCKUP_UNAUTHORIZED: felt252 = 'lockup_unauthorized';
    const INVALID_SENDER_WITHDRAWAL: felt252 = 'invalid sender withdrawal';
    const WITHDRAW_TO_ZERO_ADDRESS: felt252 = 'withdraw to zero address';
    const WITHDRAW_ZERO_AMOUNT: felt252 = 'withdraw zero amount';
    const OVERDRAW: felt252 = 'Amount more than available';
    const DEPOSIT_AMOUNT_ZERO: felt252 = 'deposit amount is zero';
    const START_TIME_GREAT_THAN_CLIFF_TIME: felt252 = 'start time > cliff time';

    const TOTAL_AMOUNT_TOO_LOW: felt252 = 'total amount too low';
    const CLIFF_TIME_LESS_THAN_END_TIME: felt252 = 'cliff time < end time';
    const CURRENT_TIME_GREATER_THAN_END_TIME: felt252 = 'current time > end time';
    const NO_PROTOCOL_REVENUE: felt252 = 'No protocol revenues to claim';

    fn protocol_fee_too_high(protocol_fee: u128, max_fee: u128) {
        panic(array![PROTOCOL_FEE_TOO_HIGH, protocol_fee.into(), max_fee.into()])
    }

    fn broker_fee_too_high(broker_fee: u128, max_fee: u128) {
        panic(array![BROKER_FEE_TOO_HIGH, broker_fee.into(), max_fee.into()])
    }
}
