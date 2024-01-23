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
    pow_256, ADMIN, ASSET, ALICE, setup, teardown, prepare_contracts, deploy_setup_erc20,
    deploy_tokei, give_tokens_and_approve, BOB
};
use tokei::tests::utils::defaults::Defaults::{PROTOCOL_FEES, RECIPIENT, BROKER};
use tokei::tests::utils::defaults::Defaults;

use tokei::tokens::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};

// Local imports.
use tokei::core::lockup_linear::{ITokeiLockupLinearDispatcher, ITokeiLockupLinearDispatcherTrait};
use tokei::types::lockup_linear::{Range, Broker, LockupLinearStream};
use tokei::types::lockup::LockupAmounts;
use tokei::tokens::erc721::{IERC721SafeDispatcher, IERC721SafeDispatcherTrait};

/// TODO: Implement actual test and change the name of this function.
#[test]
fn test_set_protocol_fee() {
    let (tokei) = setup(ADMIN());
    tokei.set_protocol_fee(ASSET(), PROTOCOL_FEES);
    let fee = tokei.get_protocol_fee(ASSET());

    assert(fee == 1, 'Incorrect fee');
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
// #[test]
// fn test_create_default_stream_with_range() {
//     let (tokei) = setup(ADMIN());
//     let recipient_address = contract_address_const::<0>();
//     let (_, _, total_amount, _, cancelable, transferable, range, broker) =
//         Defaults::create_with_range();
//     start_prank(CheatTarget::One(tokei.contract_address), ALICE());

//     tokei.set_protocol_fee(ASSET(), PROTOCOL_FEES);

//     let value = tokei.get_protocol_fee(ASSET());

//     let stream_id = tokei
//         .create_with_range(
//             ALICE(),
//             recipient_address,
//             total_amount,
//             ASSET(),
//             cancelable,
//             transferable,
//             range,
//             broker,
//         );
//     stop_prank(CheatTarget::One(tokei.contract_address));

//     assert(2 == 2, 'Invalid StreamId');
// }

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

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());

    tokei.set_protocol_fee(token, PROTOCOL_FEES);

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

fn create_with_duration() -> (ITokeiLockupLinearDispatcher, IERC20Dispatcher, u64) {
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
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
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
    tokei.set_protocol_fee(token, PROTOCOL_FEES);
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
    'streamed_amount_of'.print();
    streamed_amount_of.print();

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
    'actual_status'.print();
    actual_status.print();
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
    'streamed_amount_of'.print();
    streamed_amount_of.print();
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
    'actual_streamed_amount'.print();
    actual_streamed_amount.print();
    // stop_warp(CheatTarget::One(tokei.contract_address));

    let expected_streamed_amount = 7497;

    assert(actual_streamed_amount == expected_streamed_amount, 'Invalid streamed amount');
}

#[test]
fn test_streamed_amount_of_cliff_time_in_present_1() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let actual_streamed_amount = tokei.streamed_amount_of(stream_id);
    'actual_streamed_amount'.print();
    actual_streamed_amount.print();
    // stop_warp(CheatTarget::One(tokei.contract_address));

    let expected_streamed_amount = 9997;

    assert(actual_streamed_amount == expected_streamed_amount, 'Invalid streamed amount');
}

#[test]
fn test_withdrawable_amount_of_cliff_time() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);
    'actual_streamed_amount'.print();
    withdrawable_amount_of.print();

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
}

#[test]
fn test_withdraw_by_recipient() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);
    'actual_streamed_amount'.print();
    withdrawable_amount_of.print();

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());

    tokei.withdraw(stream_id, RECIPIENT(), 9996);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9996_u256;
    assert(balance == expected_balance, 'Invalid balance');
}

#[test]
fn test_withdraw_by_approved_caller() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);
    'actual_streamed_amount'.print();
    withdrawable_amount_of.print();

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    stream_nft.approve(BOB(), stream_id.into());

    stop_prank(CheatTarget::One(tokei.contract_address));

    start_prank(CheatTarget::One(tokei.contract_address), BOB());

    tokei.withdraw(stream_id, RECIPIENT(), 9996);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9996_u256;
    assert(balance == expected_balance, 'Invalid balance');
}

#[test]
fn test_withdraw_by_caller() {
    let (tokei, token, stream_id) = create_with_duration();
    start_warp(CheatTarget::One(tokei.contract_address), 5000);

    let withdrawable_amount_of = tokei.withdrawable_amount_of(stream_id);
    'actual_streamed_amount'.print();
    withdrawable_amount_of.print();

    assert(withdrawable_amount_of == 9997, 'Invalid withdrawable amount');
    let stream_nft = IERC721SafeDispatcher { contract_address: tokei.contract_address };

    // start_prank(CheatTarget::One(tokei.contract_address), RECIPIENT());
    // stream_nft.approve(ALICE(), stream_id.into());

    // let val = stream_nft.get_approved(stream_id.into());
    // 'val'.print();
    // val.unwrap().print();
    // stop_prank(CheatTarget::One(tokei.contract_address));

    start_prank(CheatTarget::One(tokei.contract_address), ALICE());

    tokei.withdraw(stream_id, RECIPIENT(), 9996);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9996_u256;
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

    tokei.withdraw(stream_id, BOB(), 9996);

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

    tokei.withdraw(stream_id, RECIPIENT(), 9996);

    let balance = token.balance_of(RECIPIENT());
    let expected_balance = 9996_u256;
    assert(balance == expected_balance, 'Invalid balance');
}


// #[should_panic(expected: ('NO ACTIVE LOCK OR NOT OWNER',))]

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
