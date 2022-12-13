// SPDX-License-Identifier: MIT
// StarkVest Contracts for Cairo v0.0.1 (test_starkvest.cairo)

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256

// OpenZeplin
from openzeppelin.access.ownable.library import Ownable

// Project dependencies
from starkvest.library import StarkVest
from starkvest.model import Vesting, MAX_SLICE_PERIOD_SECONDS, MAX_TIMESTAMP

const VESTING_TOKEN_ADDRESS = 'vesting-token-address';
const ADMIN = 'starkvest-admin';
const ANYONE_1 = 'user-1';
const ANYONE_2 = 'user-2';
const ANYONE_3 = 'user-3';

// -------
// STRUCTS
// -------

struct Signers {
    admin: felt,
    anyone_1: felt,
    anyone_2: felt,
    anyone_3: felt,
}

struct Mocks {
    vesting_token_address: felt,
}

struct TestContext {
    signers: Signers,
    mocks: Mocks,
}

namespace test_internal {
    func prepare{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        test_context: TestContext
    ) {
        alloc_locals;

        local signers: Signers = Signers(
            admin=ADMIN, anyone_1=ANYONE_1, anyone_2=ANYONE_2, anyone_3=ANYONE_3
        );

        local mocks: Mocks = Mocks(vesting_token_address=VESTING_TOKEN_ADDRESS);

        local context: TestContext = TestContext(signers=signers, mocks=mocks);
        Ownable.initializer(signers.admin);
        StarkVest.initializer(mocks.vesting_token_address);
        return (test_context=context);
    }
}

// Test case: create vesting in normal conditions and valid parameters
// Category: NOMINAL
// Expected result: create_vesting must succeed and return a valid vesting_id
@external
func test_create_vesting_nominal_case{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 1000;
    let duration = 3600;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    assert_not_zero(vesting_id);
    %{ stop() %}
    return ();
}

// Test case: create vesting and vest some tokens
// Category: NOMINAL
// Expected result: some tokens are vested
@external
func test_vest_some_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 1000;
    let duration = 3600;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    assert_not_zero(vesting_id);
    %{ stop() %}

    %{ stop_warp = warp(2800) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    %{ stop_warp() %}

    assert vested_amount = Uint256(500, 0);

    %{ stop_warp = warp(3700) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    %{ stop_warp() %}

    assert vested_amount = Uint256(750, 0);

    %{ stop_warp = warp(3988) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    %{ stop_warp() %}

    assert vested_amount = Uint256(830, 0);

    %{ stop_warp = warp(4600) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    %{ stop_warp() %}

    assert vested_amount = Uint256(1000, 0);
    return ();
}

// Test case: create vesting without enough available tokens
// Category: BAD_CONDITIONS
// Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_not_enough_tokens{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [999, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 1000;
    let duration = 3600;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: not enough available tokens") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}
    return ();
}

// Test case: create vesting with an invalid cliff delta
// Category: INVALID_PARAMETERS
// Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_invalid_cliff_delta{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    let beneficiary = context.signers.anyone_1;
    let cliff_delta = MAX_TIMESTAMP;
    let start = 1000;
    let duration = 3600;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    %{ stop=start_prank(ids.context.signers.admin) %}

    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: value is not a valid timestamp in the context of StarkVest") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}
    return ();
}

// Test case: create vesting with an invalid cliff delta
// Category: INVALID_PARAMETERS
// Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_invalid_beneficiary{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    let beneficiary = 0;
    let cliff_delta = 0;
    let start = 1000;
    let duration = 3600;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    %{ stop=start_prank(ids.context.signers.admin) %}

    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: cannot set the beneficiary to zero address") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}
    return ();
}

// Test case: create vesting with an invalid end of vesting timestamp
// Category: INVALID_PARAMETERS
// Details: vesting cannot end after January 1, 3000
// Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_invalid_vesting_end{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 2;
    let duration = MAX_TIMESTAMP - 2;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    %{ stop=start_prank(ids.context.signers.admin) %}

    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: value is not a valid timestamp in the context of StarkVest") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}
    return ();
}

// Test case: revoke vesting in normal conditions
// Category: NOMINAL
// Expected result: revoke must succeed
@external
func test_revoke_nominal_case{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop=start_prank(ids.context.signers.admin) %}

    //##
    // Create the vesting
    //##
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 1000;
    let duration = 3600;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );

    //##
    // Assert that vesting is not revoked
    //##
    let (vesting) = StarkVest.vestings(vesting_id);
    assert vesting.revoked = FALSE;

    // ##
    // Revoke the vesting
    //##
    %{ expect_events({"name": "VestingRevoked", "data": [ids.vesting_id]},) %}
    StarkVest.revoke(vesting_id);

    //##
    // Assert that vesting is revoked
    //##
    let (vesting) = StarkVest.vestings(vesting_id);
    assert vesting.revoked = TRUE;

    %{ stop() %}
    return ();
}

// Test case: revoke vesting in normal conditions
// Category: BAD_CONDITIONS
// Expected result: revoke must fail and revert with correct message
@external
func test_revoke_not_revocable{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop=start_prank(ids.context.signers.admin) %}

    //##
    // Create the vesting
    //##
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 1000;
    let duration = 3600;
    let slice_period_seconds = 1;
    let revocable = FALSE;
    let amount_total = Uint256(1000, 0);
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );

    // ##
    // Revoke the vesting
    // Must fail
    //##
    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: vesting is not revocable") %}
    StarkVest.revoke(vesting_id);

    %{ stop() %}
    return ();
}

// Test case: release some tokens in normal conditions
// Category: NOMINAL
// Expected result: release must succeed
@external
func test_release_nominal_case{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    //##
    // Create the vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 0;
    let duration = 1000;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}

    //##
    // Assert that amount of tokens released is 0
    //##
    let (vesting) = StarkVest.vestings(vesting_id);
    assert vesting.released = Uint256(0, 0);

    //##
    // Got to timestamp 100
    //##
    %{ stop_warp = warp(100) %}
    let (releasable_amount) = StarkVest.releasable_amount(vesting_id);
    assert releasable_amount = Uint256(100, 0);

    // ##
    // Release 100 tokens
    //##
    %{ stop=start_prank(ids.context.signers.anyone_1) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "transfer", [1]) %}
    StarkVest.release(vesting_id, Uint256(100, 0));
    %{ stop() %}
    %{ stop_warp() %}

    //##
    // Assert that amount of tokens released is 100
    //##
    let (vesting) = StarkVest.vestings(vesting_id);
    assert vesting.released = Uint256(100, 0);

    //##
    // Assert that releasable amount is now 0
    //##
    let (releasable_amount) = StarkVest.releasable_amount(vesting_id);
    assert releasable_amount = Uint256(0, 0);

    return ();
}

// Test case: withdraw some tokens in normal conditions
// Category: NOMINAL
// Expected result: withdraw must succeed
@external
func test_withdraw_nominal_case{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "transfer", [1]) %}
    StarkVest.withdraw(Uint256(1000, 0));
    %{ stop() %}

    return ();
}

// Test case: withdraw tokens but not enough withdrawable tokens
// Category: BAD_CONDITIONS
// Expected result: withdraw must fail and revert with correct message
@external
func test_withdraw_not_enough_tokens{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [999, 0]) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "transfer", [1]) %}
    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: cannot withdraw tokens, not enough withdrawable tokens") %}
    StarkVest.withdraw(Uint256(1000, 0));
    %{ stop() %}

    return ();
}

// Test case: retreive amount from multi vestings (two) for one account
// Category: NOMINAL
// Expected result: release must succeed
@external
func test_releasable_amount_all_for_two_vestings_nominal_case{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 0;
    let duration = 1000;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);

    //##
    // Create the frist vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}

    //##
    // Create the second vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}

    %{ stop_warp = warp(1000) %}
    let (vesting_count) = StarkVest.vesting_count(context.signers.anyone_1);
    assert vesting_count = 2;
    let (vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(2000, 0);

    return ();
}

// Test case: retreive amount from multi vestings (three) for one account
// Category: NOMINAL
// Expected result: release must succeed
@external
func test_releasable_amount_all_for_three_vestings_nominal_case{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let slice_period_seconds = 1;
    let revocable = TRUE;

    //##
    // Create the frist vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [4000, 0]) %}
    let start = 3000;
    let duration = 1;
    let amount_total = Uint256(1000, 0);
    let (vesting_id_1) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}

    //##
    // Create the second vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    let start = 1000;
    let duration = 3600;
    let amount_total = Uint256(2000, 0);
    let (vesting_id_2) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}

    //##
    // Create the third vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    let start = 1000;
    let duration = 3600;
    let amount_total = Uint256(1000, 0);
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    assert_not_zero(vesting_id);
    %{ stop() %}

    %{ stop_warp = warp(2800) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    let (vesting_count) = StarkVest.vesting_count(context.signers.anyone_1);
    assert vesting_count = 3;
    let (total_vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(500, 0);
    assert total_vested_amount = Uint256(1500, 0);

    %{ stop_warp = warp(3700) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    let (total_vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(750, 0);
    assert total_vested_amount = Uint256(3250, 0);

    %{ stop_warp = warp(3988) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    let (total_vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(830, 0);
    assert total_vested_amount = Uint256(3490, 0);

    %{ stop_warp = warp(4600) %}
    let (vested_amount) = StarkVest.releasable_amount(vesting_id);
    let (total_vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(1000, 0);
    assert total_vested_amount = Uint256(4000, 0);
    return ();
}

// Test case: retreive amount from multi vestings (two) for one account
// Category: BOUNDARY
// Expected result: release must succeed
@external
func test_releasable_amount_all_no_vestings{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    %{ stop_warp = warp(1000) %}
    let (vesting_count) = StarkVest.vesting_count(context.signers.anyone_1);
    assert vesting_count = 0;
    let (vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(0, 0);

    return ();
}

// Test case: retreive amount from multi vestings (two) for one account
// Category: BOUNDARY
// Expected result: release must succeed
@external
func test_releasable_amount_all_one_vestings{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    //##
    // Create the frist vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 3000;
    let duration = 1;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    let (vesting_id_1) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}

    %{ stop_warp = warp(1000) %}
    let (vesting_count) = StarkVest.vesting_count(context.signers.anyone_1);
    assert vesting_count = 1;
    let (vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(0, 0);

    %{ stop_warp = warp(3000) %}
    let (vesting_count) = StarkVest.vesting_count(context.signers.anyone_1);
    assert vesting_count = 1;
    let (vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(0, 0);

    %{ stop_warp = warp(3001) %}
    let (vesting_count) = StarkVest.vesting_count(context.signers.anyone_1);
    assert vesting_count = 1;
    let (vested_amount) = StarkVest.releasable_amount_all_vestings(context.signers.anyone_1);
    %{ stop_warp() %}

    assert vested_amount = Uint256(1000, 0);

    return ();
}

// Test case: retreive amount from multi vestings (two) for one account
// Category: BOUNDARY
// Expected result: release must succeed
@external
func test_releasable_amount_all_no_account{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;
    let (local context: TestContext) = test_internal.prepare();

    //##
    // Create the frist vesting
    //##
    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1;
    let cliff_delta = 0;
    let start = 1;
    let duration = 50;
    let slice_period_seconds = 1;
    let revocable = TRUE;
    let amount_total = Uint256(1000, 0);
    let (vesting_id_1) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
    %{ stop() %}

    %{ stop_warp = warp(1000) %}
    let (vesting_count) = StarkVest.vesting_count(0);
    assert vesting_count = 0;
    let (vested_amount) = StarkVest.releasable_amount_all_vestings(0);
    %{ stop_warp() %}

    assert vested_amount = Uint256(0, 0);

    return ();
}
