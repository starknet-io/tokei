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
use snforge_std::{declare, start_prank, stop_prank, ContractClassTrait};


// Local imports.
use tokei::core::lockup_linear::{
    ITokeiLockupLinearSafeDispatcher, ITokeiLockupLinearSafeDispatcherTrait
};
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
    // *********************************************************************************************
    // *                              TEST LOGIC                                                   *
    // *********************************************************************************************

    // Define variables.
    let sender = caller_address;
    let recipient = contract_address_const::<'recipient'>();
    let total_amount = 1000;
    let asset = contract_address_const::<'asset'>();
    let cancelable = true;
    let start = 10;
    let cliff = 100;
    let end = 1000;
    let range = Range { start, cliff, end, };
    let broker_account = caller_address;
    let broker_fee = 0;
    let broker = Broker { account: broker_account, fee: broker_fee, };

    // Actual test.
    let stream_id = tokei
        .create_with_range(sender, recipient, total_amount, asset, cancelable, range, broker,)
        .unwrap();

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
fn setup(caller_address: ContractAddress) -> (ITokeiLockupLinearSafeDispatcher,) {
    // Setup the contracts.
    let (tokei,) = setup_contracts(caller_address);
    // Prank the caller address.
    prepare_contracts(caller_address, tokei,);
    // Return the caller address and the contract interfaces.
    (tokei,)
}

// Utility function to prank the caller address
fn prepare_contracts(caller_address: ContractAddress, tokei: ITokeiLockupLinearSafeDispatcher,) {
    // Prank the caller address for calls to `TokeiLockupLinear` contract.
    start_prank(tokei.contract_address, caller_address);
}

/// Utility function to teardown the test environment.
fn teardown(tokei: ITokeiLockupLinearSafeDispatcher,) {
    stop_prank(tokei.contract_address);
}

/// Setup required contracts.
fn setup_contracts(caller_address: ContractAddress) -> (ITokeiLockupLinearSafeDispatcher,) {
    // Deploy the role store contract.
    let tokei_address = deploy_tokei(caller_address);

    // Create a role store dispatcher.
    let tokei = ITokeiLockupLinearSafeDispatcher { contract_address: tokei_address };

    // Return the caller address and the contract interfaces.
    (tokei,)
}


/// Utility function to deploy a `TokeiLockupLinear` contract and return its address.
fn deploy_tokei(initial_admin: ContractAddress) -> ContractAddress {
    let tokei_contract = declare('TokeiLockupLinear');
    let mut constructor_calldata = array![initial_admin.into()];
    tokei_contract.deploy(@constructor_calldata).unwrap()
}

