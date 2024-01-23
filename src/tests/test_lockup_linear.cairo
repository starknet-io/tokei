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
use integer::BoundedInt;

// Starknet Foundry imports.
use snforge_std::{
    declare, ContractClassTrait, start_prank, stop_prank, RevertedTransaction, CheatTarget,
    TxInfoMock, start_warp, stop_warp
};

use tokei::tests::utils::utils::Utils::{
    pow_256, ADMIN, ASSET, ALICE,CHARLIE, setup, teardown, prepare_contracts, deploy_setup_erc20,
    deploy_tokei, give_tokens_and_approve, BOB,
};
use tokei::tests::utils::defaults::Defaults::{PROTOCOL_FEES, RECIPIENT, BROKER};
use tokei::tests::utils::defaults::Defaults;

use tokei::tokens::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};

// Local imports.
use tokei::core::lockup_linear::{ITokeiLockupLinearDispatcher, ITokeiLockupLinearDispatcherTrait};
use tokei::types::lockup_linear::{Range, Broker,Durations, LockupLinearStream};
use tokei::types::lockup::LockupAmounts;
use tokei::tokens::erc721::{IERC721SafeDispatcher, IERC721SafeDispatcherTrait};

/// TODO: Implement actual test and change the name of this function.

fn create_with_duration() -> (ITokeiLockupLinearDispatcher, IERC20Dispatcher, u64) {
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', 100000000, ADMIN()
    );
    let recipient_address = RECIPIENT();
    let approve_token_to = array![ALICE(),BOB(),CHARLIE()];
    give_tokens_and_approve(
        approve_token_to, token, token_dispatcher, ADMIN(), tokei.contract_address
    );

    let (alice, recipient, total_amount, _, cancelable, transferable, range, broker) =
        Defaults::create_with_durations();
    start_prank(CheatTarget::One(tokei.contract_address),  ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    stop_prank(CheatTarget::One(tokei.contract_address));
    let initial_protocol_revenues = tokei.get_protocol_revenues(token);
    start_prank(CheatTarget::One(tokei.contract_address), ALICE());
    start_warp(CheatTarget::One(tokei.contract_address), 1000);

    let stream_id = tokei
        .create_with_duration(
            ALICE(),
            recipient_address,
            total_amount,
            token,
            cancelable,
            transferable,
            range,
            broker,
        );
    stop_warp(CheatTarget::One(tokei.contract_address));
    stop_prank(CheatTarget::One(tokei.contract_address));
    (tokei, token_dispatcher, stream_id)
}
#[test]
fn test_set_protocol_fee() {
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', BoundedInt::max(), ADMIN()
    );
    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    let fee = tokei.get_protocol_fee(token);
    stop_prank(CheatTarget::One(tokei.contract_address));

    assert(fee == 1, 'Incorrect fee');
}

#[test]
fn test_set_nft_descriptor() {
    let tokei_contract = declare('TokeiLockupLinear');
        let mut constructor_calldata = array![ADMIN().into()];
        let random_addr = contract_address_const::<'random'>();
        let tokei_addr = tokei_contract.deploy(@constructor_calldata).unwrap();
        // let tokei_address = deploy_tokei(caller_address);

        // Create a role store dispatcher.
        let tokei = ITokeiLockupLinearDispatcher { contract_address: tokei_addr };
    start_prank(CheatTarget::One(tokei_addr), ADMIN());
    tokei.set_nft_descriptor(random_addr);
    let fee = tokei.get_nft_descriptor();
    stop_prank(CheatTarget::One(tokei_addr));

    assert(1 == 1, 'Incorrect fee');
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
fn test_create_stream_with_range() {
    // *************************************************************************
    //                               EXPECTED RESULTS
    let expected_stream_id = 1;
    let expected_ALICE_balance = 990000;
    let expected_Broker_balance = 3;
    let expected_protocol_revenue = 1;
    // *************************************************************************
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', BoundedInt::max(), ADMIN()
    );
    let recipient_address = RECIPIENT();
    let approve_token_to = array![ALICE()];
    give_tokens_and_approve(
        approve_token_to, token, token_dispatcher, ADMIN(), tokei.contract_address
    );
    let (_, _, total_amount, _, cancelable, transferable, range, broker) =
        Defaults::create_with_range();

    let balance = token_dispatcher.balance_of(ALICE());

    

    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    stop_prank(CheatTarget::One(tokei.contract_address));

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());

    let initial_protocol_revenues = tokei.get_protocol_revenues(token);

    let ALICE_balance = token_dispatcher.balance_of(ALICE());

    let value = tokei.get_protocol_fee(token);

    let stream_id = tokei
        .create_with_range(
            ALICE(),
            recipient_address,
            total_amount,
            token,
            cancelable,
            transferable,
            range,
            broker,
        );
    stop_prank(CheatTarget::One(tokei.contract_address));

    let ALICE_balance = token_dispatcher.balance_of(ALICE());

    let expected_protocol_revenues = initial_protocol_revenues + PROTOCOL_FEES;

    assert(ALICE_balance == expected_ALICE_balance, 'Invalid ALICE balance');

    let Broker_balance = token_dispatcher.balance_of(broker.account);
    assert(Broker_balance == expected_Broker_balance, 'Invalid Broker balance');

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    let protocol_revenue = tokei.get_protocol_revenues(token);
    assert(protocol_revenue == expected_protocol_revenue, 'Invalid protocol revenue');

    // Check that the stream nft was minted to the recipient.
    assert(
        stream_nft.owner_of(stream_id.into()).unwrap() == recipient_address,
        'wrong stream nft owner'
    );

    assert(stream_nft.balance_of(recipient_address).unwrap() == 1, 'wrong stream nft balance');
    assert(stream_id == expected_stream_id, 'Invalid StreamId');
}



#[test]
fn test_create_with_duration() {
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', BoundedInt::max(), ADMIN()
    );
    let recipient_address = RECIPIENT();
    let approve_token_to = array![ALICE()];
    give_tokens_and_approve(
        approve_token_to, token, token_dispatcher, ADMIN(), tokei.contract_address
    );

    let (alice, recipient, total_amount, _, cancelable, transferable, range, broker) =
        Defaults::create_with_durations();
    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    stop_prank(CheatTarget::One(tokei.contract_address));
    let initial_protocol_revenues = tokei.get_protocol_revenues(token);

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());
    start_warp(CheatTarget::One(tokei.contract_address), 100);

    let stream_id = tokei
        .create_with_duration(
            ALICE(),
            recipient_address,
            total_amount,
            token,
            cancelable,
            transferable,
            range,
            broker,
        );

    let streamed_amount_of = tokei.streamed_amount_of(stream_id);

    stop_warp(CheatTarget::One(tokei.contract_address));
    stop_prank(CheatTarget::One(tokei.contract_address));

    // *************************************************************************
    //                               EXPECTED RESULTS
    let expected_stream_id = 1;
    let expected_ALICE_balance = 990000;
    let expected_Broker_balance = 3;
    let expected_protocol_revenue = 1;
    let expected_stream = LockupLinearStream {
        sender: ALICE(),
        asset: token,
        start_time: 100,
        cliff_time: 100 + 2500,
        end_time: 100 + 10000,
        is_cancelable: true,
        was_canceled: false,
        is_depleted: false,
        is_stream: true,
        is_transferable: true,
        amounts: LockupAmounts { deposited: 9997, withdrawn: 0, refunded: 0, }
    };
    // *************************************************************************

    let protocol_revenue = tokei.get_protocol_revenues(token);
    assert(protocol_revenue == expected_protocol_revenue, 'Invalid protocol revenue');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    let expected_protocol_revenues = initial_protocol_revenues + PROTOCOL_FEES;

    let protocol_revenue = tokei.get_protocol_revenues(token);
    let actual_status = tokei.is_warm(stream_id);

    assert(protocol_revenue == expected_protocol_revenue, 'Invalid protocol revenue');

    // Check that the stream nft was minted to the recipient.
    assert(
        stream_nft.owner_of(stream_id.into()).unwrap() == recipient_address,
        'wrong stream nft owner'
    );
    assert(stream_nft.balance_of(recipient_address).unwrap() == 1, 'wrong stream nft balance');
    assert(actual_status == true, 'Incorrect status');
    assert(stream_id == 1, 'wrong stream id');
    start_warp(CheatTarget::One(tokei.contract_address), 10000);
    let streamed_amount_of = tokei.streamed_amount_of(stream_id);

    // stop_warp(CheatTarget::One(tokei.contract_address));

    assert(
        tokei.get_stream(stream_id).amounts.deposited == expected_stream.amounts.deposited,
        'Invalid stream'
    );

    assert(
        stream_nft.owner_of(stream_id.into()).unwrap() == recipient_address,
        'wrong stream nft owner'
    );

    assert(tokei.get_next_stream_id() == 2, 'Invalid next stream id');
}



#[test]
#[should_panic(expected: ('deposit amount is zero',))]
fn test_create_with_duration_when_amount_is_zero() {
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', BoundedInt::max(), ADMIN()
    );
    let recipient_address = RECIPIENT();
    let approve_token_to = array![ALICE()];
    give_tokens_and_approve(
        approve_token_to, token, token_dispatcher, ADMIN(), tokei.contract_address
    );

    let total_amount = 0;

    let (alice, recipient, _, _, cancelable, transferable, range, broker) =
        Defaults::create_with_durations();
        start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    stop_prank(CheatTarget::One(tokei.contract_address));
    let initial_protocol_revenues = tokei.get_protocol_revenues(token);

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());
    start_warp(CheatTarget::One(tokei.contract_address), 100);

    let stream_id = tokei
        .create_with_duration(
            ALICE(),
            recipient_address,
            total_amount,
            token,
            cancelable,
            transferable,
            range,
            broker,
        );

    let streamed_amount_of = tokei.streamed_amount_of(stream_id);

    stop_warp(CheatTarget::One(tokei.contract_address));
    stop_prank(CheatTarget::One(tokei.contract_address));
}

#[test]
#[should_panic(expected: ('start time > cliff time',))]
fn test_create_with_duration_when_cliff_is_less_than_start() {
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', BoundedInt::max(), ADMIN()
    );
    let recipient_address = RECIPIENT();
    let approve_token_to = array![ALICE()];
    give_tokens_and_approve(
        approve_token_to, token, token_dispatcher, ADMIN(), tokei.contract_address
    );

    let (_, _, total_amount, _, cancelable, transferable, _, broker) =
        Defaults::create_with_range();
    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    stop_prank(CheatTarget::One(tokei.contract_address));
    let initial_protocol_revenues = tokei.get_protocol_revenues(token);

    let range = Range { start : 1000, cliff: 100, end: 6000, };

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());
    start_warp(CheatTarget::One(tokei.contract_address), 1000);

    let stream_id = tokei
        .create_with_range(
            ALICE(),
            recipient_address,
            total_amount,
            token,
            cancelable,
            transferable,
            range,
            broker,
        );

    let streamed_amount_of = tokei.streamed_amount_of(stream_id);

    stop_warp(CheatTarget::One(tokei.contract_address));
    stop_prank(CheatTarget::One(tokei.contract_address));
}

#[test]
fn test_all_the_getters_with_respect_to_stream(){
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', BoundedInt::max(), ADMIN()
    );
    let recipient_address = RECIPIENT();
    let approve_token_to = array![ALICE()];
    give_tokens_and_approve(
        approve_token_to, token, token_dispatcher, ADMIN(), tokei.contract_address
    );

    let (alice, recipient, total_amount, _, cancelable, transferable, range, broker) =
        Defaults::create_with_durations();
    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    stop_prank(CheatTarget::One(tokei.contract_address));
    let initial_protocol_revenues = tokei.get_protocol_revenues(token);

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());
    start_warp(CheatTarget::One(tokei.contract_address), 100);

    let stream_id = tokei
        .create_with_duration(
            ALICE(),
            recipient_address,
            total_amount,
            token,
            cancelable,
            transferable,
            range,
            broker,
        );

    let get_start_time = tokei.get_start_time(stream_id);
    assert(get_start_time == 100, 'Incorrect start time');
    let get_asset = tokei.get_asset(stream_id);
    assert(get_asset == token, 'Incorrect asset');
    let get_recipient = tokei.get_recipient(stream_id);
    assert(get_recipient == recipient_address, 'Incorrect recipient');
    let get_cliff_time = tokei.get_cliff_time(stream_id);
    assert(get_cliff_time == 100 + 2500, 'Incorrect cliff time');
    let get_deposited_amount = tokei.get_deposited_amount(stream_id);
    assert(get_deposited_amount == 9997, 'Incorrect deposited amount');
    let get_end_time = tokei.get_end_time(stream_id);
    assert(get_end_time == 100 + 4000, 'Incorrect end time');
    let get_range = tokei.get_range(stream_id);
    assert(get_range.start == 100, 'Incorrect start');
    assert(get_range.cliff == 100 + 2500 , 'Incorrect cliff');
    assert(get_range.end == 100 + 4000, 'Incorrect end');

    let get_refunded_amount = tokei.get_refunded_amount(stream_id);
    assert(get_refunded_amount == 0, 'Incorrect refunded amount');
    let get_sender = tokei.get_sender(stream_id);
    assert(get_sender == ALICE(), 'Incorrect sender');
    let get_withdrawn_amount = tokei.get_withdrawn_amount(stream_id);
    assert(get_withdrawn_amount == 0, 'Incorrect withdrawn amount');
    let is_cancelable = tokei.is_cancelable(stream_id);
    assert(is_cancelable == true, 'Incorrect cancelable');
    let is_transferable = tokei.is_transferable(stream_id);
    assert(is_transferable == true, 'Incorrect transferable');
    let is_depleted = tokei.is_depleted(stream_id);
    assert(is_depleted == false, 'Incorrect depleted');
    let is_stream = tokei.is_stream(stream_id);
    assert(is_stream == true, 'Incorrect stream');
    let refundable_amount_of = tokei.refundable_amount_of(stream_id);
    assert(refundable_amount_of == 9997, 'Incorrect refundable amount');
    let get_refunded_amount = tokei.get_refunded_amount(stream_id);
    assert(get_refunded_amount == 0, 'Incorrect refunded amount');
    let is_cold = tokei.is_cold(stream_id);
    assert(is_cold == false, 'Incorrect cold');
    let is_warm = tokei.is_warm(stream_id);
    assert(is_warm == true, 'Incorrect warm');
    let was_canceled = tokei.was_canceled(stream_id);
    assert(was_canceled == false, 'Incorrect was canceled');
}


#[test]
fn test_get_cliff_time() {
    let (tokei, token, stream_id) = create_with_duration();
    let cliff_time = tokei.get_cliff_time(stream_id);
    let expected_cliff_time = 1000 + 2500;

    assert(cliff_time == expected_cliff_time, 'Invalid cliff time');
}

#[test]
fn test_get_cliff_time_when_null() {
    let (tokei, token, _) = create_with_duration();
    let stream_id = 102;
    let cliff_time = tokei.get_cliff_time(stream_id);
    let expected_cliff_time = 0;

    assert(cliff_time == expected_cliff_time, 'Invalid cliff time');
}

#[test]
fn test_get_range() {
    let (tokei, token, stream_id) = create_with_duration();
    let range = tokei.get_range(stream_id);
    let expected_range = Range { start: 1000, cliff: 1000 + 2500, end: 1000 + 4000, };

    assert(range == expected_range, 'Invalid range');
}

#[test]
fn test_get_range_when_null() {
    let (tokei, token, _) = create_with_duration();
    let stream_id = 102;
    let range = tokei.get_range(stream_id);
    let expected_range = Range { start: 0, cliff: 0, end: 0, };

    assert(range == expected_range, 'Invalid range');
}

#[test]
fn test_get_stream_when_status_settled() {
    let (tokei, token, stream_id) = create_with_duration();

    start_warp(CheatTarget::One(tokei.contract_address), 1000000);

    let actual_stream = tokei.get_stream(stream_id);
    let expected_stream = LockupLinearStream {
        sender: ALICE(),
        asset: token.contract_address,
        start_time: 1000,
        cliff_time: 1000 + 2500,
        end_time: 1000 + 4000,
        is_cancelable: false,
        was_canceled: false,
        is_depleted: false,
        is_stream: true,
        is_transferable: true,
        amounts: LockupAmounts { deposited: 9997, withdrawn: 0, refunded: 0, }
    };

    assert(actual_stream == expected_stream, 'Invalid stream');
}

#[test]
fn test_get_stream_when_not_settled() {
    let (tokei, token, stream_id) = create_with_duration();

    start_warp(CheatTarget::One(tokei.contract_address), 10000);

    let actual_stream = tokei.get_stream(stream_id);

    let expected_stream = LockupLinearStream {
        sender: ALICE(),
        asset: token.contract_address,
        start_time: 1000,
        cliff_time: 1000 + 2500,
        end_time: 1000 + 4000,
        is_cancelable: false,
        was_canceled: false,
        is_depleted: false,
        is_stream: true,
        is_transferable: true,
        amounts: LockupAmounts { deposited: 9997, withdrawn: 0, refunded: 0, }
    };

    assert(actual_stream == expected_stream, 'Invalid stream');
}

#[test]
fn test_streamed_amount_of_cliff_time_in_past() {
    let (tokei, token, stream_id) = create_with_duration();

    let actual_streamed_amount = tokei.streamed_amount_of(stream_id);

    let expected_streamed_amount = 0;

    assert(actual_streamed_amount == expected_streamed_amount, 'Invalid streamed amount');
}

#[test]
fn test_streamed_amount_of_cliff_time_in_present() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 4000);

    let actual_streamed_amount = tokei.streamed_amount_of(stream_id);

    let expected_streamed_amount = 7497;

    assert(actual_streamed_amount == expected_streamed_amount, 'Invalid streamed amount');
}

#[test]
fn test_streamed_amount_of_cliff_time_in_present_1() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let actual_streamed_amount = tokei.streamed_amount_of(stream_id);


    let expected_streamed_amount = 9997;

    assert(actual_streamed_amount == expected_streamed_amount, 'Invalid streamed amount');
}

#[test]
fn test_withdrawable_amount_of_cliff_time() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
}

#[test]
fn test_withdraw_by_recipient() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());

    tokei.withdraw(stream_id, RECIPIENT(), withdrawable_amount_of);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9997_u256;
    assert(balance == expected_balance, 'Invalid balance');
}

#[test]
fn test_withdraw_by_recipient_before_total_time() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 3600);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);

    assert(withdrawable_amount_of == 6498, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());

    tokei.withdraw(stream_id, RECIPIENT(), withdrawable_amount_of);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 6498;
    assert(balance == expected_balance, 'Invalid balance');
}

#[test]
fn test_withdraw_by_approved_caller() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    stream_nft.approve(BOB(), stream_id.into());

    stop_prank(CheatTarget::One(tokei.contract_address));

    start_prank(CheatTarget::One(tokei.contract_address), BOB());

    tokei.withdraw(stream_id, RECIPIENT(), withdrawable_amount_of);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9997_u256;
    assert(balance == expected_balance, 'Invalid balance');
}

#[test]
fn test_withdraw_by_caller() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);
    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());

    tokei.withdraw(stream_id, RECIPIENT(), withdrawable_amount_of);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9997_u256;
    assert(balance == expected_balance, 'Invalid balance');
}
#[test]
#[should_panic(expected: ('invalid sender withdrawal',))]
fn test_withdraw_by_approved_caller_to_other_address_than_recipient() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };
    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    stream_nft.approve(BOB(), stream_id.into());

    let addr = stream_nft.owner_of(stream_id.into());

    stop_prank(CheatTarget::One(tokei.contract_address));

    start_prank(CheatTarget::One(tokei.contract_address), BOB());

    tokei.withdraw(stream_id, BOB(), withdrawable_amount_of);
}

#[test]
#[should_panic(expected: ('lockup_unauthorized',))]
fn test_withdraw_by_unapproved_caller() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), BOB());

    tokei.withdraw(stream_id, RECIPIENT(), withdrawable_amount_of);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9997_u256;
    assert(balance == expected_balance, 'Invalid balance');
}

#[test]
fn test_withdraw_max() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());

    tokei.withdraw_max(stream_id, RECIPIENT());

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9997_u256;
    assert(balance == expected_balance, 'Invalid balance');
}

#[test]
fn test_withdraw_max_and_transfer() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    let recipient_nft_balance_before = stream_nft.balance_of(RECIPIENT());
    assert(recipient_nft_balance_before.unwrap() == 1, 'Invalid nft balance');
    let bob_nft_balance_before = stream_nft.balance_of(BOB());
    assert(bob_nft_balance_before.unwrap() == 0, 'Invalid nft balance');

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());

    tokei.withdraw_max_and_transfer(stream_id, BOB());

    let balance = token.balance_of( RECIPIENT());
    let expected_balance = 9997_u256;
    assert(balance == expected_balance, 'Invalid balance');

    let recipient_nft_balance_after = stream_nft.balance_of(RECIPIENT());
    assert(recipient_nft_balance_after.unwrap() == 0, 'Invalid nft balance');

    let bob_nft_balance_after = stream_nft.balance_of(BOB());
    assert(bob_nft_balance_after.unwrap() == 1, 'Invalid nft balance');

}

#[test]
#[should_panic(expected: ('Stream is not transferable',))]
fn test_withdraw_max_and_transfer_when_not_transferable() {
    let transferable = false;
    let (tokei) = setup(ADMIN());
    let (token_dispatcher, token) = deploy_setup_erc20(
        'Ethereum', 'ETH', 100000000, ADMIN()
    );
    let recipient_address = RECIPIENT();
    let approve_token_to = array![ALICE()];
    give_tokens_and_approve(
        approve_token_to, token, token_dispatcher, ADMIN(), tokei.contract_address
    );

    let (alice, recipient, total_amount, _, cancelable, _, range, broker) =
        Defaults::create_with_durations();
    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
    stop_prank(CheatTarget::One(tokei.contract_address));
    let initial_protocol_revenues = tokei.get_protocol_revenues(token);
    start_prank(CheatTarget::One(tokei.contract_address), ALICE());
    start_warp(CheatTarget::One(tokei.contract_address), 1000);

    let stream_id = tokei
        .create_with_duration(
            ALICE(),
            recipient_address,
            total_amount,
            token,
            cancelable,
            transferable,
            range,
            broker,
        );
    stop_warp(CheatTarget::One(tokei.contract_address));
    stop_prank(CheatTarget::One(tokei.contract_address));
  

    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    let recipient_nft_balance_before = stream_nft.balance_of(RECIPIENT());
    assert(recipient_nft_balance_before.unwrap() == 1, 'Invalid nft balance');
    let bob_nft_balance_before = stream_nft.balance_of(BOB());
    assert(bob_nft_balance_before.unwrap() == 0, 'Invalid nft balance');

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());

    tokei.withdraw_max_and_transfer(stream_id, BOB());

}

#[test]
fn test_withdraw_multiple() {
    let (_, _, _, _, _, _, _, broker) =
        Defaults::create_with_durations();
 
    let total_amount_2 = 10000;
    let cancelable_2 = true;
    let transferable_2 = true;
    let durations_2 = Durations { cliff: 2500, total: 6000, };

    let total_amount_3 = 12000;
    let cancelable_3 = false;
    let transferable_3 = false;
    let durations_3 = Durations { cliff: 4000, total: 6500, };

    let reciever = contract_address_const::<'reciever'>();



     let (tokei, token, stream_id_1) = create_with_duration();
    

    start_prank(CheatTarget::One(tokei.contract_address), BOB());
    start_warp(CheatTarget::One(tokei.contract_address), 1000);

    let stream_id_2 = tokei
        .create_with_duration(
            BOB(),
            RECIPIENT(),
            total_amount_2,
            token.contract_address,
            cancelable_2,
            transferable_2,
            durations_2,
            broker,
        );

        
        stop_prank(CheatTarget::One(tokei.contract_address));

        start_prank(CheatTarget::One(tokei.contract_address), CHARLIE());
        let stream_id_3 = tokei.create_with_duration(
            CHARLIE(),
            RECIPIENT(),
            total_amount_3,
            token.contract_address,
            cancelable_3,
            transferable_3,
            durations_3,
            broker,
        );

        stop_warp(CheatTarget::One(tokei.contract_address));
        
    start_warp(CheatTarget::One(tokei.contract_address), 10000);
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    let recipient_nft_balance_before = stream_nft.balance_of(RECIPIENT());
    assert(recipient_nft_balance_before.unwrap() == 3, 'Invalid nft balance');


    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    stream_nft.approve(reciever, stream_id_1.into());
    stream_nft.approve(reciever, stream_id_2.into());
    stream_nft.approve(reciever, stream_id_3.into());
    stop_prank(CheatTarget::One(tokei.contract_address));

    start_prank(CheatTarget::One(tokei.contract_address), reciever);
    let stream_ids = array![stream_id_1, stream_id_2, stream_id_3];
    let amounts = array![9997, 6000, 11000];
    tokei.withdraw_multiple(
        stream_ids.span(),
        RECIPIENT(),
        amounts.span(),
    );

    let balance = token.balance_of( RECIPIENT());
    let expected_balance = 26997_u256;
    assert(balance == expected_balance, 'Invalid balance');
    assert(tokei.get_protocol_revenues(token.contract_address) == 3, 'Invalid protocol revenue');

    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    let admin_balance_before = token.balance_of( ADMIN());
    tokei.claim_protocol_revenues(token.contract_address);
    let admin_balance_after = token.balance_of( ADMIN());
    let expected_admin_balance = admin_balance_before + 3;
    assert(admin_balance_after == expected_admin_balance, 'Invalid admin balance');


}

// fn test_burn_token() {
//     let (tokei, token, stream_id) = create_with_duration();
//     let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

//     start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
//     stream_nft.burn(stream_id.into());
//     stop_prank(CheatTarget::One(tokei.contract_address));

//     let balance = token.balance_of(RECIPIENT());
//     let expected_balance = 9997_u256;
//     assert(balance == expected_balance, 'Invalid balance');
// }

#[test]
fn test_burn_token_when_depleted() {
        
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 8000);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());

    tokei.withdraw_max(stream_id, RECIPIENT());

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9997_u256;
    assert(balance == expected_balance, 'Invalid balance');
    
    let old_tokei_nft_balance = stream_nft.balance_of(RECIPIENT());
    assert(old_tokei_nft_balance.unwrap() == 1, 'Invalid nft balance');

    tokei.burn_token(stream_id);

    let new_tokei_nft_balance = stream_nft.balance_of(RECIPIENT());
    assert(new_tokei_nft_balance.unwrap() == 0, 'Invalid nft balance');

}

#[test]
#[should_panic(expected: ('stream has not depleted',))]
fn test_burn_token_when_not_depleted() {
        
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 4100);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());

    tokei.withdraw_max(stream_id, RECIPIENT());

    let balance = token.balance_of(RECIPIENT());

    let expected_balance = 7797_u256;
    assert(balance == expected_balance, 'Invalid balance');
    
    let old_tokei_nft_balance = stream_nft.balance_of(RECIPIENT());
    assert(old_tokei_nft_balance.unwrap() == 1, 'Invalid nft balance');

    tokei.burn_token(stream_id);

    let new_tokei_nft_balance = stream_nft.balance_of(RECIPIENT());
    assert(new_tokei_nft_balance.unwrap() == 0, 'Invalid nft balance');

}

#[test]
fn test_cancel() {
    let (tokei, token, stream_id) = create_with_duration();
    let before_balance_of_sender = token.balance_of(ALICE());

    start_warp(CheatTarget::One(tokei.contract_address), 4100);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };
    let stream = tokei.get_stream(stream_id);

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    tokei.cancel(stream_id);

    let after_balance_of_sender = token.balance_of(ALICE());

    assert(before_balance_of_sender != after_balance_of_sender,'Balance did not change');
    assert(tokei.is_cancelable(stream_id) == false, 'Invalid stream');
}

#[test]
#[should_panic(expected: ('stream_settled',))]
fn test_cancel_should_panic() {
    let (tokei, token, stream_id) = create_with_duration();
    let before_balance_of_sender = token.balance_of(ALICE());

    start_warp(CheatTarget::One(tokei.contract_address), 7000);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };
    let stream = tokei.get_stream(stream_id);

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    tokei.cancel(stream_id);
}

#[test]
fn test_renounce() {
    let (tokei, token, stream_id) = create_with_duration();
    

    start_warp(CheatTarget::One(tokei.contract_address), 4100);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };
    

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());
    tokei.renounce(stream_id);

    assert(tokei.is_cancelable(stream_id) == false, 'Invalid stream');
}

#[test]
#[should_panic(expected: ('lockup_unauthorized',))]
fn test_renounce_by_recipient() {
     let (tokei, token, stream_id) = create_with_duration();
  
    start_warp(CheatTarget::One(tokei.contract_address), 4100);

    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };
    
    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    tokei.renounce(stream_id);

    assert(tokei.is_cancelable(stream_id) == false, 'Invalid stream');

}

#[test]
fn test_transfer_admin() {
    let (tokei, token, stream_id) = create_with_duration();

    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.transfer_admin(BOB());

    assert(tokei.get_admin() == BOB(), 'Invalid admin');
}


#[test]
#[should_panic(expected: ('lockup_unauthorized',))]
fn test_set_protocol_fee_panic() {
    let (tokei, token, stream_id) = create_with_duration();

    start_prank(CheatTarget::One(tokei.contract_address), BOB());
    tokei.set_protocol_fee(token.contract_address, 100);
}

#[test]
fn test_set_flash_fee() {
    let (tokei, token, stream_id) = create_with_duration();

    start_prank(CheatTarget::One(tokei.contract_address), ADMIN());
    tokei.set_flash_fee(100);

    assert(tokei.get_flash_fee() == 100, 'Invalid protocol fee');
}

#[test]
#[should_panic(expected: ('lockup_unauthorized',))]
fn test_set_flash_fee_panic() {
    let (tokei, token, stream_id) = create_with_duration();

    start_prank(CheatTarget::One(tokei.contract_address), BOB());
    tokei.set_flash_fee(100);
}




impl LockupLinearStreamPrintTrait of PrintTrait<LockupLinearStream> {
    fn print(self: LockupLinearStream) {
        let message = array![
            'LockupLinearStream: ',
            self.sender.into(),
            self.asset.into(),
            self.start_time.into(),
            self.cliff_time.into(),
            self.end_time.into(),
            self.is_cancelable.into(),
            self.was_canceled.into(),
            self.is_depleted.into(),
            self.is_stream.into(),
            self.is_transferable.into(),
        ];
        message.print();
    }
}
