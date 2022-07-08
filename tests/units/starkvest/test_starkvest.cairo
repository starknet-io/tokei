# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (test_starkvest.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256

# Project dependencies
from starkvest.library import StarkVest
from starkvest.model import Vesting, MAX_SLICE_PERIOD_SECONDS, MAX_TIMESTAMP

const VESTING_TOKEN_ADDRESS = 'vesting-token-address'
const ADMIN = 'starkvest-admin'
const ANYONE_1 = 'user-1'
const ANYONE_2 = 'user-2'
const ANYONE_3 = 'user-3'

# -------
# STRUCTS
# -------

struct Signers:
    member admin : felt
    member anyone_1 : felt
    member anyone_2 : felt
    member anyone_3 : felt
end

struct Mocks:
    member vesting_token_address : felt
end

struct TestContext:
    member signers : Signers
    member mocks : Mocks
end

# Test case: create vesting in normal conditions and valid parameters
# Category: NOMINAL
# Expected result: create_vesting must succeed and return a valid vesting_id
@external
func test_create_vesting_nominal_case{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local context : TestContext) = test_internal.prepare()

    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [2000, 0]) %}
    let beneficiary = context.signers.anyone_1
    let cliff_delta = 0
    let start = 1000
    let duration = 3600
    let slice_period_seconds = 1
    let revocable = TRUE
    let amount_total = Uint256(1000, 0)
    let (vesting_id) = StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    )
    assert_not_zero(vesting_id)
    %{ stop() %}
    return ()
end

# Test case: create vesting without enough available tokens
# Category: BAD_CONDITIONS
# Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_not_enough_tokens{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local context : TestContext) = test_internal.prepare()

    %{ stop=start_prank(ids.context.signers.admin) %}
    %{ mock_call(ids.context.mocks.vesting_token_address, "balanceOf", [999, 0]) %}
    let beneficiary = context.signers.anyone_1
    let cliff_delta = 0
    let start = 1000
    let duration = 3600
    let slice_period_seconds = 1
    let revocable = TRUE
    let amount_total = Uint256(1000, 0)
    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: not enough available tokens") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    )
    %{ stop() %}
    return ()
end

# Test case: create vesting with an invalid cliff delta
# Category: INVALID_PARAMETERS
# Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_invalid_cliff_delta{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local context : TestContext) = test_internal.prepare()

    let beneficiary = context.signers.anyone_1
    let cliff_delta = MAX_TIMESTAMP
    let start = 1000
    let duration = 3600
    let slice_period_seconds = 1
    let revocable = TRUE
    let amount_total = Uint256(1000, 0)
    %{ stop=start_prank(ids.context.signers.admin) %}

    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: value is not a valid timestamp in the context of StarkVest") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    )
    %{ stop() %}
    return ()
end

# Test case: create vesting with an invalid cliff delta
# Category: INVALID_PARAMETERS
# Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_invalid_beneficiary{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local context : TestContext) = test_internal.prepare()

    let beneficiary = 0
    let cliff_delta = 0
    let start = 1000
    let duration = 3600
    let slice_period_seconds = 1
    let revocable = TRUE
    let amount_total = Uint256(1000, 0)
    %{ stop=start_prank(ids.context.signers.admin) %}

    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: cannot set the beneficiary to zero address") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    )
    %{ stop() %}
    return ()
end

# Test case: create vesting with an invalid end of vesting timestamp
# Category: INVALID_PARAMETERS
# Details: vesting cannot end after January 1, 3000
# Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_invalid_vesting_end{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local context : TestContext) = test_internal.prepare()

    let beneficiary = context.signers.anyone_1
    let cliff_delta = 0
    let start = 2
    let duration = MAX_TIMESTAMP - 2
    let slice_period_seconds = 1
    let revocable = TRUE
    let amount_total = Uint256(1000, 0)
    %{ stop=start_prank(ids.context.signers.admin) %}

    %{ expect_revert("TRANSACTION_FAILED", "StarkVest: value is not a valid timestamp in the context of StarkVest") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    )
    %{ stop() %}
    return ()
end

# Test case: create vesting from non owner account
# Category: ACCESS_CONTROL
# Expected result: create_vesting must fail and revert with correct message
@external
func test_create_vesting_from_non_owner_account{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local context : TestContext) = test_internal.prepare()

    let beneficiary = context.signers.anyone_1
    let cliff_delta = 0
    let start = 1
    let duration = 3600
    let slice_period_seconds = 1
    let revocable = TRUE
    let amount_total = Uint256(1000, 0)
    %{ stop=start_prank(ids.context.signers.anyone_1) %}

    %{ expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner") %}
    StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    )
    %{ stop() %}
    return ()
end

namespace test_internal:
    func prepare{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        test_context : TestContext
    ):
        alloc_locals

        local signers : Signers = Signers(admin=ADMIN, anyone_1=ANYONE_1, anyone_2=ANYONE_2, anyone_3=ANYONE_3)

        local mocks : Mocks = Mocks(
            vesting_token_address=VESTING_TOKEN_ADDRESS,
            )

        local context : TestContext = TestContext(
            signers=signers,
            mocks=mocks,
            )

        StarkVest.constructor(signers.admin, mocks.vesting_token_address)
        return (test_context=context)
    end
end
