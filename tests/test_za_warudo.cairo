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
use cheatcodes::PreparedContract;

// Local imports.
use za_warudo::core::{IZaWarudoSafeDispatcher, IZaWarudoSafeDispatcherTrait};

/// TODO: Implement actual test and change the name of this function.
#[test]
fn init_test() {
    // *********************************************************************************************
    // *                              SETUP                                                        *
    // *********************************************************************************************

    let (caller_address, za_warudo,) = setup();
    // *********************************************************************************************
    // *                              TEST LOGIC                                                   *
    // *********************************************************************************************

    // Empty test for now.

    // *********************************************************************************************
    // *                              TEARDOWN                                                     *
    // *********************************************************************************************
    teardown(za_warudo);
}

/// Utility function to setup the test environment.
fn setup() -> ( // This caller address will be used with `start_prank` cheatcode to mock the caller address.,
    ContractAddress, // Interface to interact with the `ZaWarudo` contract.
     IZaWarudoSafeDispatcher,
) {
    // Setup the contracts.
    let (caller_address, za_warudo,) = setup_contracts();
    // Prank the caller address.
    prepare_contracts(caller_address, za_warudo,);
    // Return the caller address and the contract interfaces.
    (caller_address, za_warudo,)
}

// Utility function to prank the caller address
fn prepare_contracts(caller_address: ContractAddress, za_warudo: IZaWarudoSafeDispatcher,) {
    // Prank the caller address for calls to `ZaWarudo` contract.
    start_prank(za_warudo.contract_address, caller_address);
}

/// Utility function to teardown the test environment.
fn teardown(za_warudo: IZaWarudoSafeDispatcher,) {
    stop_prank(za_warudo.contract_address);
}

/// Setup required contracts.
fn setup_contracts() -> ( // This caller address will be used with `start_prank` cheatcode to mock the caller address.,
    ContractAddress, // Interface to interact with the `ZaWarudo` contract.
     IZaWarudoSafeDispatcher,
) {
    let caller_address = contract_address_const::<'caller'>();
    // Deploy the role store contract.
    let za_warudo_address = deploy_za_warudo();

    // Create a role store dispatcher.
    let za_warudo = IZaWarudoSafeDispatcher { contract_address: za_warudo_address };

    // Return the caller address and the contract interfaces.
    (caller_address, za_warudo,)
}


/// Utility function to deploy a `ZaWarudo` contract and return its address.
fn deploy_za_warudo() -> ContractAddress {
    let class_hash = declare('ZaWarudo');
    let mut constructor_calldata = array![];
    let prepared = PreparedContract {
        class_hash: class_hash, constructor_calldata: @constructor_calldata
    };
    deploy(prepared).unwrap()
}

