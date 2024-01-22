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

use tokei::tests::utils::utils::Utils::{
    pow_128, ADMIN, ASSET, ALICE, setup, teardown, prepare_contracts, deploy_setup_erc20,
    deploy_tokei
};
use tokei::tests::utils::defaults::Defaults::{PROTOCOL_FEES};
use tokei::tests::utils::defaults::Defaults;

use tokei::tokens::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};

// Local imports.
use tokei::core::lockup_linear::{ITokeiLockupLinearDispatcher, ITokeiLockupLinearDispatcherTrait};
use tokei::types::lockup_linear::{Range, Broker};
use tokei::tokens::erc721::{IERC721SafeDispatcher, IERC721SafeDispatcherTrait};

/// TODO: Implement actual test and change the name of this function.
#[test]
fn test_set_protocol_fee() {
    let (tokei) = setup(ADMIN());
    tokei.set_protocol_fee(ASSET(), PROTOCOL_FEES);
    let fee = tokei.get_protocol_fee(ASSET());

    assert(fee == 1000000000000000, 'Incorrect fee');
}


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
    tokei.set_protocol_fee(asset, PROTOCOL_FEES);
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
#[test]
fn test_create_default_stream_with_range() {
    let (tokei) = setup(ADMIN());
    let recipient_address = contract_address_const::<0>();
    let (_, _, total_amount, _, cancelable, transferable, range, broker) =
        Defaults::create_with_range();
    start_prank(CheatTarget::One(tokei.contract_address), ALICE());

    tokei.set_protocol_fee(ASSET(), PROTOCOL_FEES);

    let value = tokei.get_protocol_fee(ASSET());

    let stream_id = tokei
        .create_with_range(
            ALICE(),
            recipient_address,
            total_amount,
            ASSET(),
            cancelable,
            transferable,
            range,
            broker,
        );
    stop_prank(CheatTarget::One(tokei.contract_address));

    assert(1 == 2, 'Invalid StreamId');
}

