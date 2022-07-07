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
func vesting_total_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    vesting_total_amount : Uint256
):
    return StarkVest.vesting_total_amount()
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

@external
func create_vesting{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    beneficiary : felt,
    cliff : felt,
    start : felt,
    duration : felt,
    slicePeriodSeconds : felt,
    revocable : felt,
    amountTotal : Uint256,
) -> (vesting_id : felt):
    return StarkVest.create_vesting(
        beneficiary, cliff, start, duration, slicePeriodSeconds, revocable, amountTotal
    )
end
