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
    const OVERDRAW : felt252 = 'Amount more than available';

    fn protocol_fee_too_high(protocol_fee: u128, max_fee: u128) {
        panic(array![PROTOCOL_FEE_TOO_HIGH, protocol_fee.into(), max_fee.into()])
    }

    fn broker_fee_too_high(broker_fee: u128, max_fee: u128) {
        panic(array![BROKER_FEE_TOO_HIGH, broker_fee.into(), max_fee.into()])
    }
}
