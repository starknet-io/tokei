mod Defaults {
    use starknet::{
        ContractAddress, get_caller_address, Felt252TryIntoContractAddress, contract_address_const,
        ClassHash,
    };
    use tokei::types::lockup_linear::{LockupLinearStream, Range, Durations, Broker};
    use tokei::types::lockup::{LockupAmounts, CreateAmounts};
    use tokei::tests::utils::constants::Constants;
    use tokei::tests::utils::types::Users;
    use tokei::tests::utils::utils::Utils::{
        pow_256, ADMIN, BROKER, RECIPIENT, ASSET, ALICE, setup, teardown, prepare_contracts,
        deploy_setup_erc20, deploy_tokei
    };


    const BROKER_FEE: u256 = 3; //0.03%
    const BROKER_FEE_AMOUNT: u256 = 30_120_481_927_710_843_373_000;
    const CLIFF_AMOUNT: u256 = 2_500_000_000_000_000_000_000;
    const CLIFF_DURATION: u64 = 2500;
    const DEPOSIT_AMOUNT: u256 = 10_000_000_000_000_000_000_000;
    const PROTOCOL_FEES: u256 = 1; //0.01%
    const PROTOCOL_FEE_AMOUNT: u256 = 10_040_160_642_570_281_124_000;
    const REFUND_AMOUNT: u256 = 7_500_000_000_000_000_000_000;
    const TOTAL_AMOUNT: u256 = 10_000;
    const TOTAL_DURATION: u64 = 4000;
    const WITHDRAW_AMOUNT: u256 = 2_600_000_000_000_000_000_000;


    fn setup_1() -> (u64, u64, u64) {
        let START_TIME = Constants::MAY_1_2023 + 172_800;
        let CLIFF_TIME = START_TIME + CLIFF_DURATION;
        let END_TIME = START_TIME + TOTAL_DURATION;

        (START_TIME, CLIFF_TIME, END_TIME)
    }

    fn lockup_amounts() -> LockupAmounts {
        LockupAmounts { deposited: DEPOSIT_AMOUNT, refunded: 0, withdrawn: 0, }
    }

    fn broker() -> Broker {
        Broker { account: BROKER(), fee: BROKER_FEE, }
    }

    fn durations() -> Durations {
        Durations { cliff: CLIFF_DURATION, total: TOTAL_DURATION, }
    }

    fn lockup_create_amounts() -> CreateAmounts {
        CreateAmounts {
            deposit: DEPOSIT_AMOUNT,
            protocol_fee: PROTOCOL_FEE_AMOUNT,
            broker_fee: BROKER_FEE_AMOUNT,
        }
    }

    fn lockup_linear_range() -> Range {
        let (START_TIME, CLIFF_TIME, END_TIME) = setup_1();
        Range { start: START_TIME, cliff: CLIFF_TIME, end: END_TIME, }
    }

    fn lockup_linear_stream() -> LockupLinearStream {
        let (START_TIME, CLIFF_TIME, END_TIME) = setup_1();
        LockupLinearStream {
            sender: contract_address_const::<'sender'>(),
            asset: contract_address_const::<'asset'>(),
            start_time: START_TIME,
            cliff_time: CLIFF_TIME,
            end_time: END_TIME,
            is_cancelable: true,
            was_canceled: false,
            is_depleted: false,
            is_stream: true,
            is_transferable: true,
            amounts: lockup_amounts(),
        }
    }

    fn create_with_durations() -> (
        ContractAddress, ContractAddress, u256, ContractAddress, bool, bool, Durations, Broker
    ) {
        // let asset = contract_address_const::<'asset'>();
        let broker = broker();
        let cancelable = true;
        let durations = durations();
        // let recipient = contract_address_const::<'recipient'>();
        // let sender = contract_address_const::<'sender'>();
        let total_amount = TOTAL_AMOUNT;

        (ALICE(), RECIPIENT(), total_amount, ASSET(), cancelable, true, durations, broker)
    }

    fn create_with_range() -> (
        ContractAddress, ContractAddress, u256, ContractAddress, bool, bool, Range, Broker
    ) {
        // let asset = contract_address_const::<'asset'>();
        let broker = broker();
        let cancelable = true;
        let range = lockup_linear_range();
        // let recipient = contract_address_const::<'recipient'>();
        // let sender = contract_address_const::<'sender'>();
        let total_amount = TOTAL_AMOUNT;

        (ALICE(), RECIPIENT(), total_amount, ASSET(), cancelable, true, range, broker)
    }
}
