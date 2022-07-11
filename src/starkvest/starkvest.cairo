# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (starkvest.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

# Project dependencies
from starkvest.library import StarkVest
from starkvest.model import Vesting

# -----
# VIEWS
# -----

@view
func erc20_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    erc20_address : felt
):
    return StarkVest.erc20_address()
end

@view
func vestings_total_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    vestings_total_amount : Uint256
):
    return StarkVest.vestings_total_amount()
end

@view
func vesting_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (vesting_count : felt):
    return StarkVest.vesting_count(account)
end

@view
func vestings{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    vesting_id : felt
) -> (vesting : Vesting):
    return StarkVest.vestings(vesting_id)
end

@view
func withdrawable_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    withdrawable_amount : Uint256
):
    return StarkVest.withdrawable_amount()
end

@view
func get_contract_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    balance : Uint256
):
    return StarkVest.get_contract_balance()
end

###
# Compute and return releaseable amount of tokens for a vesting.
# @param vesting_id the vesting identifier
# @return the amount of releaseable / vested tokens
###
@view
func releaseable_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    vesting_id : felt
) -> (releaseable_amount : Uint256):
    return StarkVest.releaseable_amount(vesting_id)
end

# -----
# CONSTRUCTOR
# -----

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, erc20_address : felt
):
    return StarkVest.constructor(owner, erc20_address)
end

# -----
# EXTERNAL FUNCTIONS
# -----

###
# Creates a new vesting for a beneficiary.
# @param beneficiary address of the beneficiary to whom vested tokens are transferred
# @param _start start time of the vesting period
# @param cliff_delta duration in seconds of the cliff in which tokens will begin to vest
# @param duration duration in seconds of the period in which the tokens will vest
# @param slice_period_seconds duration of a slice period for the vesting in seconds
# @param revocable whether the vesting is revocable or not
# @param amount_total total amount of tokens to be released at the end of the vesting
# @return the created vesting id
###
@external
func create_vesting{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    beneficiary : felt,
    cliff_delta : felt,
    start : felt,
    duration : felt,
    slice_period_seconds : felt,
    revocable : felt,
    amount_total : Uint256,
) -> (vesting_id : felt):
    return StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    )
end

###
# Revokes the vesting identified by vesting_id.
# @param vesting_id the vesting identifier
# @return the amount of releaseable tokens
###
@external
func revoke{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(vesting_id : felt):
    return StarkVest.revoke(vesting_id)
end
