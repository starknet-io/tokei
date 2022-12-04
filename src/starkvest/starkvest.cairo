// SPDX-License-Identifier: MIT
// StarkVest Contracts for Cairo v0.1.0 (starkvest.cairo)

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

// Project dependencies
from starkvest.library import StarkVest
from starkvest.model import Vesting

// -----
// VIEWS
// -----

@view
func erc20_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    erc20_address: felt
) {
    return StarkVest.erc20_address();
}

//##
// @return the total amount locked in vestings
//##
@view
func vestings_total_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    vestings_total_amount: Uint256
) {
    return StarkVest.vestings_total_amount();
}

//##
// @return the number of vestings associated to the account
//##
@view
func vesting_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (vesting_count: felt) {
    return StarkVest.vesting_count(account);
}

//##
// @return the number of vestings associated to the account
//##
@view
func get_vesting_id{pedersen_ptr: HashBuiltin*}(
    account: felt, vesting_index: felt
) -> (vesting_id: felt) {
    return StarkVest.compute_vesting_id(account, vesting_index);
}

@view
func vestings{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    vesting_id: felt
) -> (vesting: Vesting) {
    return StarkVest.vestings(vesting_id);
}

//##
// Compute and return the amount of tokens withdrawable by the owner.
// @return the amount of withdrawable tokens
//##
@view
func withdrawable_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    withdrawable_amount: Uint256
) {
    return StarkVest.withdrawable_amount();
}

@view
func get_contract_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    balance: Uint256
) {
    return StarkVest.get_contract_balance();
}

//##
// Compute and return releasable amount of tokens for a vesting.
// @param vesting_id the vesting identifier
// @return the amount of releasable / vested tokens
//##
@view
func releasable_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    vesting_id: felt
) -> (releasable_amount: Uint256) {
    return StarkVest.releasable_amount(vesting_id);
}

// -----
// CONSTRUCTOR
// -----

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, erc20_address: felt
) {
    return StarkVest.constructor(owner, erc20_address);
}

// -----
// EXTERNAL FUNCTIONS
// -----

//##
// Creates a new vesting for a beneficiary.
// @param beneficiary address of the beneficiary to whom vested tokens are transferred
// @param _start start time of the vesting period
// @param cliff_delta duration in seconds of the cliff in which tokens will begin to vest
// @param duration duration in seconds of the period in which the tokens will vest
// @param slice_period_seconds duration of a slice period for the vesting in seconds
// @param revocable whether the vesting is revocable or not
// @param amount_total total amount of tokens to be released at the end of the vesting
// @return the created vesting id
//##
@external
func create_vesting{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    beneficiary: felt,
    cliff_delta: felt,
    start: felt,
    duration: felt,
    slice_period_seconds: felt,
    revocable: felt,
    amount_total: Uint256,
) -> (vesting_id: felt) {
    return StarkVest.create_vesting(
        beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
    );
}

//##
// Revokes the vesting identified by vesting_id.
// @param vesting_id the vesting identifier
// @return the amount of releasable tokens
//##
@external
func revoke{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(vesting_id: felt) {
    return StarkVest.revoke(vesting_id);
}

//##
// Release vested amount of tokens.
// @param vesting_id the vesting identifier
// @param amount the amount to release
//##
@external
func release{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    vesting_id: felt, amount: Uint256
) {
    return StarkVest.release(vesting_id, amount);
}

//##
// Witdraw an amount of tokens from the vesting contract.
// @param amount the amount to withdraw
//##
@external
func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) {
    return StarkVest.withdraw(amount);
}
