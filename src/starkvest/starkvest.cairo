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
