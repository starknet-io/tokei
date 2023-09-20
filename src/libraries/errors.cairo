mod Lockup {
    const PROTOCOL_FEE_TOO_HIGH: felt252 = 'protocol_fee_too_high';
    const BROKER_FEE_TOO_HIGH: felt252 = 'broker_fee_too_high';

    fn protocol_fee_too_high(protocol_fee: u128, max_fee: u128) {
        panic(array![PROTOCOL_FEE_TOO_HIGH, protocol_fee.into(), max_fee.into()])
    }

    fn broker_fee_too_high(broker_fee: u128, max_fee: u128) {
        panic(array![BROKER_FEE_TOO_HIGH, broker_fee.into(), max_fee.into()])
    }
}
