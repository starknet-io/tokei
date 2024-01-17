//! Test file for `src/core/lockup_linear.cairo`.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::{TryInto, Into};
use starknet::{
    ContractAddress, get_caller_address, Felt252TryIntoContractAddress, contract_address_const,
    ClassHash,
};
use debug::PrintTrait;

// Starknet Foundry imports.
use snforge_std::{
    declare, ContractClassTrait, start_prank, stop_prank, RevertedTransaction, CheatTarget,
    TxInfoMock,
};

use tokei::tokens::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};


// Local imports.
use tokei::core::lockup_linear::{ITokeiLockupLinearDispatcher, ITokeiLockupLinearDispatcherTrait};
use tokei::types::lockup_linear::{Range, Broker};
use tokei::tokens::erc721::{IERC721SafeDispatcher, IERC721SafeDispatcherTrait};

/// TODO: Implement actual test and change the name of this function.
#[test]
fn given_normal_conditions_when_create_with_range_then_expected_results() {
    // *********************************************************************************************
    // *                              SETUP                                                        *
    // *********************************************************************************************
    let caller_address = contract_address_const::<'caller'>();

    let (tokei) = setup(caller_address);
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', 100000_u256, caller_address
    );
    start_prank(CheatTarget::One(token), caller_address);
    token_dispatcher.approve(tokei.contract_address, 1000_u256);
    stop_prank(CheatTarget::One(token));

    // *********************************************************************************************
    // *                              TEST LOGIC                                                   *
    // *********************************************************************************************

    // Define variables.
    let sender = caller_address;
    let recipient = contract_address_const::<'recipient'>();
    let total_amount = 1000;
    let asset = token;
    let cancelable = true;
    let transferable = true;
    let start = 10;
    let cliff = 100;
    let end = 1000;
    let range = Range { start, cliff, end, };
    let broker_account = caller_address;
    let broker_fee = 0;
    let broker = Broker { account: broker_account, fee: broker_fee, };

    prepare_contracts(caller_address, tokei);
    // Actual test.
    let stream_id = tokei
        .create_with_range(
            sender, recipient, total_amount, asset, cancelable, transferable, range, broker,
        );

    // Assertions.
    assert(stream_id == 1, 'wrong stream id');

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    // Check that the stream nft was minted to the recipient.
    assert(stream_nft.owner_of(stream_id.into()).unwrap() == recipient, 'wrong stream nft owner');
    assert(stream_nft.balance_of(recipient).unwrap() == 1, 'wrong stream nft balance');

    // *********************************************************************************************
    // *                              TEARDOWN                                                     *
    // *********************************************************************************************
    teardown(tokei);
}

/// Utility function to setup the test environment.
fn setup(caller_address: ContractAddress) -> (ITokeiLockupLinearDispatcher,) {
    // Setup the contracts.
    let (tokei,) = setup_contracts(caller_address);
    // Prank the caller address.
    prepare_contracts(caller_address, tokei,);
    // Return the caller address and the contract interfaces.
    (tokei,)
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

/// Setup required contracts.
fn setup_contracts(caller_address: ContractAddress) -> (ITokeiLockupLinearDispatcher,) {
    // Deploy the role store contract.
    let tokei_address = deploy_tokei(caller_address);

    // Create a role store dispatcher.
    let tokei = ITokeiLockupLinearDispatcher { contract_address: tokei_address };

    // Return the caller address and the contract interfaces.
    (tokei,)
}


/// Utility function to deploy a `TokeiLockupLinear` contract and return its address.
fn deploy_tokei(initial_admin: ContractAddress) -> ContractAddress {
    let tokei_contract = declare('TokeiLockupLinear');
    let mut constructor_calldata = array![initial_admin.into()];
    tokei_contract.deploy(@constructor_calldata).unwrap()
}

fn deploy_setup_erc20(
    name: felt252, symbol: felt252, initial_supply: u256, recipient: ContractAddress
) -> (IERC20Dispatcher, ContractAddress) {
    let token_contract = declare('ERC20');
    let mut calldata = array![name, symbol];
    Serde::serialize(@initial_supply, ref calldata);
    Serde::serialize(@recipient, ref calldata);
    let token_addr = token_contract.deploy(@calldata).unwrap();
    let token_dispatcher = IERC20Dispatcher { contract_address: token_addr };

    (token_dispatcher, token_addr)
}

