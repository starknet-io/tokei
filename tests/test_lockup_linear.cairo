//! Test file for `src/deposit/deposit_vault.cairo`.

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
use cheatcodes::PreparedContract;

// Local imports.
use za_warudo::core::lockup_linear::{
    IZaWarudoLockupLinearSafeDispatcher, IZaWarudoLockupLinearSafeDispatcherTrait
};
use za_warudo::types::lockup_linear::{Range, Broker};

/// TODO: Implement actual test and change the name of this function.
#[test]
fn given_normal_conditions_when_create_with_range_then_expected_results() {
    // *********************************************************************************************
    // *                              SETUP                                                        *
    // *********************************************************************************************
    let caller_address = contract_address_const::<'caller'>();

    let (za_warudo) = setup(caller_address);
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
    let stream_id = za_warudo
        .create_with_range(sender, recipient, total_amount, asset, cancelable, range, broker,)
        .unwrap();

    // Assertions.
    assert(stream_id == 1, 'wrong stream id');

    // *********************************************************************************************
    // *                              TEARDOWN                                                     *
    // *********************************************************************************************
    teardown(za_warudo);
}

/// Utility function to setup the test environment.
fn setup(caller_address: ContractAddress) -> (IZaWarudoLockupLinearSafeDispatcher,) {
    // Setup the contracts.
    let (za_warudo,) = setup_contracts(caller_address);
    // Prank the caller address.
    prepare_contracts(caller_address, za_warudo,);
    // Return the caller address and the contract interfaces.
    (za_warudo,)
}

// Utility function to prank the caller address
fn prepare_contracts(
    caller_address: ContractAddress, za_warudo: IZaWarudoLockupLinearSafeDispatcher,
) {
    // Prank the caller address for calls to `ZaWarudoLockupLinear` contract.
    start_prank(za_warudo.contract_address, caller_address);
}

/// Utility function to teardown the test environment.
fn teardown(za_warudo: IZaWarudoLockupLinearSafeDispatcher,) {
    stop_prank(za_warudo.contract_address);
}

/// Setup required contracts.
fn setup_contracts(caller_address: ContractAddress) -> (IZaWarudoLockupLinearSafeDispatcher,) {
    // Deploy the role store contract.
    let za_warudo_address = deploy_za_warudo(caller_address);

    // Create a role store dispatcher.
    let za_warudo = IZaWarudoLockupLinearSafeDispatcher { contract_address: za_warudo_address };

    // Return the caller address and the contract interfaces.
    (za_warudo,)
}


/// Utility function to deploy a `ZaWarudoLockupLinear` contract and return its address.
fn deploy_za_warudo(initial_admin: ContractAddress) -> ContractAddress {
    let class_hash = declare('ZaWarudoLockupLinear');
    let mut constructor_calldata = array![];
    constructor_calldata.append(initial_admin.into());
    let prepared = PreparedContract {
        class_hash: class_hash, constructor_calldata: @constructor_calldata
    };
    deploy(prepared).unwrap()
}

