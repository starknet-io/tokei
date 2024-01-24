use starknet::ContractAddress;

mod Utils {
    use core::traits::TryInto;
    use starknet::ContractAddress;
    use snforge_std::{
        declare, ContractClassTrait, start_prank, stop_prank, start_spoof, CheatTarget, TxInfoMock,
        get_class_hash, ContractClass
    };
    // use tokei::tokens::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use openzeppelin::token::erc20::interface::{
        IERC20, IERC20Metadata, ERC20ABIDispatcher, ERC20ABIDispatcherTrait
    };

    // Local imports.
    use tokei::core::lockup_linear::{
        ITokeiLockupLinearDispatcher, ITokeiLockupLinearDispatcherTrait
    };


    fn pow_256(self: u256, mut exponent: u8) -> u256 {
        if self.is_zero() {
            return 0;
        }
        let mut result = 1;
        let mut base = self;

        loop {
            if exponent & 1 == 1 {
                result = result * base;
            }

            exponent = exponent / 2;
            if exponent == 0 {
                break result;
            }

            base = base * base;
        }
    }

    fn OWNER() -> ContractAddress {
        'owner'.try_into().unwrap()
    }

    fn RECIPIENT() -> ContractAddress {
        'recipient'.try_into().unwrap()
    }

    fn SPENDER() -> ContractAddress {
        'spender'.try_into().unwrap()
    }

    fn ALICE() -> ContractAddress {
        'alice'.try_into().unwrap()
    }

    fn BOB() -> ContractAddress {
        'bob'.try_into().unwrap()
    }

    fn CHARLIE() -> ContractAddress {
        'charlie'.try_into().unwrap()
    }

    fn ADMIN() -> ContractAddress {
        'admin'.try_into().unwrap()
    }

    fn ASSET() -> ContractAddress {
        'asset'.try_into().unwrap()
    }
    fn BROKER() -> ContractAddress {
        'broker'.try_into().unwrap()
    }

    /// Utility function to deploy a `TokeiLockupLinear` contract and return its address.
    fn deploy_tokei(
        initial_admin: ContractAddress
    ) -> (ContractAddress, ITokeiLockupLinearDispatcher) {
        let tokei_contract = declare('TokeiLockupLinear');
        let mut constructor_calldata = array![initial_admin.into()];
        let tokei_addr = tokei_contract.deploy(@constructor_calldata).unwrap();
        // let tokei_address = deploy_tokei(caller_address);

        // Create a role store dispatcher.
        let tokei = ITokeiLockupLinearDispatcher { contract_address: tokei_addr };
        // start

        (tokei_addr, tokei,)
    }

    fn deploy_setup_erc20(
        name: felt252, symbol: felt252, initial_supply: u256, recipient: ContractAddress
    ) -> (ERC20ABIDispatcher, ContractAddress) {
        let token_contract = declare('ERC20');
        let mut calldata = array![name, symbol];
        Serde::serialize(@initial_supply, ref calldata);
        Serde::serialize(@recipient, ref calldata);
        let token_addr = token_contract.deploy(@calldata).unwrap();
        let token_dispatcher = ERC20ABIDispatcher { contract_address: token_addr };

        (token_dispatcher, token_addr)
    }

    // Utility function to prank the caller address
    fn prepare_contracts(caller_address: ContractAddress, tokei: ITokeiLockupLinearDispatcher,) {
        // Prank the caller address for calls to `TokeiLockupLinear` contract.
        start_prank(CheatTarget::One(tokei.contract_address), caller_address);
    }

    /// Utility function to teardown the test environment.
    fn teardown(tokei: ITokeiLockupLinearDispatcher,) {
        stop_prank(CheatTarget::One(tokei.contract_address));
    }

    /// Utility function to setup the test environment.
    fn setup(caller_address: ContractAddress) -> (ITokeiLockupLinearDispatcher,) {
        // Setup the contracts.
        let (tokei_addr, tokei,) = deploy_tokei(caller_address);
        // Prank the caller address.
        // prepare_contracts(ADMIN(), tokei,);
        // tokei.set_protocol_fee(1);
        // Return the caller address and the contract interfaces.
        (tokei,)
    }

    fn give_tokens(
        recipients: Array<ContractAddress>,
        token_adrr: ContractAddress,
        token_disptacher: ERC20ABIDispatcher,
        owner: ContractAddress
    ) {
        start_prank(CheatTarget::One(token_adrr), owner);

        let mut i = 0;
        loop {
            if (i >= recipients.len()) {
                break;
            }

            let address = *recipients.at(i);
            let amount = 10000 * pow_256(10, 18);

            ERC20ABIDispatcher { contract_address: token_adrr }.transfer(address, amount.into());
            stop_prank(CheatTarget::One(token_adrr));

            i += 1;
        };
    }

    fn give_tokens_and_approve(
        recipients: Array<ContractAddress>,
        token_adrr: ContractAddress,
        token_disptacher: ERC20ABIDispatcher,
        owner: ContractAddress,
        tokei_addr: ContractAddress,
    ) {
        let mut i = 0;
        loop {
            if (i >= recipients.len()) {
                break;
            }

            let address = *recipients.at(i);
            let amount = 1000000;
            start_prank(CheatTarget::One(token_adrr), owner);
            ERC20ABIDispatcher { contract_address: token_adrr }.transfer(address, amount.into());
            stop_prank(CheatTarget::One(token_adrr));

            start_prank(CheatTarget::One(token_adrr), address);
            let amount = 1000000;

            ERC20ABIDispatcher { contract_address: token_adrr }.approve(tokei_addr, amount.into());

            stop_prank(CheatTarget::One(token_adrr));

            i += 1;
        };
    }
/// Setup required contracts.
// fn setup_contracts(caller_address: ContractAddress) -> (ITokeiLockupLinearDispatcher,) {
//     // Deploy the role store contract.
//     let tokei_address = deploy_tokei(caller_address);

//     // setting the protocol fee

//     // Create a role store dispatcher.
//     let tokei = ITokeiLockupLinearDispatcher { contract_address: tokei_address };

//     // Return the caller address and the contract interfaces.
//     (tokei,)
// }

}

