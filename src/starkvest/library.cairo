// SPDX-License-Identifier: MIT
// StarkVest Contracts for Cairo v0.0.1 (libary.cairo)

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_le, uint256_lt
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import (
    assert_not_zero,
    assert_nn,
    assert_le,
    assert_in_range,
    unsigned_div_rem,
)
from starkware.cairo.common.math_cmp import is_le, is_not_zero
from starkware.starknet.common.syscalls import (
    get_contract_address,
    get_block_timestamp,
    get_caller_address,
)

// OpenZeppelin dependencies
from openzeppelin.access.ownable.library import Ownable
from openzeppelin.security.safemath.library import SafeUint256
from openzeppelin.security.reentrancyguard.library import ReentrancyGuard
from openzeppelin.token.erc20.IERC20 import IERC20

// Project dependencies

from starkvest.model import Vesting, MAX_SLICE_PERIOD_SECONDS, MAX_TIMESTAMP
from starkvest.events import VestingCreated, VestingRevoked, TokensReleased

// ------
// STORAGE
// ------

// Address of the ERC20 token.
@storage_var
func erc20_address_() -> (erc20_address: felt) {
}

// Amount of tokens currently locked in vestings.
@storage_var
func vestings_total_amount_() -> (vesting_total_amount: Uint256) {
}

// Number of vesting per beneficiary address.
@storage_var
func vesting_count_(account: felt) -> (vesting_count: felt) {
}

// Mapping of vestings
@storage_var
func vestings_(vesting_id: felt) -> (vesting: Vesting) {
}

namespace StarkVest {
    // ------
    // VIEWS
    // ------

    //##
    // Returns the address of the ERC20 token managed by the vesting contract.
    //##
    func erc20_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        erc20_address: felt
    ) {
        return erc20_address_.read();
    }

    //##
    // Returns the total amount of tokens currently locked in vestings.
    //##
    func vestings_total_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> (vestings_total_amount: Uint256) {
        let (vestings_total_amount) = vestings_total_amount_.read();
        return (vestings_total_amount,);
    }

    //##
    // Returns the number of vestings associated to a beneficiary.
    //##
    func vesting_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        account: felt
    ) -> (vesting_count: felt) {
        let (vesting_count) = vesting_count_.read(account);
        return (vesting_count,);
    }

    //##
    // Get a vesting for a specified id.
    // @param vesting_id the identifier of the vesting
    //##
    func vestings{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        vesting_id: felt
    ) -> (vesting: Vesting) {
        let (vesting) = vestings_.read(vesting_id);
        return (vesting,);
    }

    //##
    // Returns the amount of tokens that can be withdrawn by the owner.
    // This can also be used to determine the number of tokens usable to create vestings.
    //##
    func withdrawable_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        withdrawable_amount: Uint256
    ) {
        let (contract_balance) = get_contract_balance();
        let (vestings_total_amount) = vestings_total_amount_.read();
        let (withdrawable_amount) = SafeUint256.sub_le(contract_balance, vestings_total_amount);
        return (withdrawable_amount,);
    }

    //##
    // Get current contract balance.
    //##
    func get_contract_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> (balance: Uint256) {
        let (erc20_address) = erc20_address_.read();
        let (contract_address) = get_contract_address();
        let (balance) = IERC20.balanceOf(erc20_address, contract_address);
        return (balance,);
    }

    //##
    // Compute and return releasable amount of tokens for a vesting.
    // @param vesting_id the vesting identifier
    // @return the amount of releasable tokens
    //##
    func releasable_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        vesting_id: felt
    ) -> (releasable_amount: Uint256) {
        let (vesting) = vestings_.read(vesting_id);
        with_attr error_message("StarkVest: invalid beneficiary") {
            assert_not_zero(vesting.beneficiary);
        }
        let (releasable_amount) = _releasable_amount(vesting);
        return (releasable_amount,);
    }

    // ------
    // CONSTRUCTOR
    // ------
    func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        owner: felt, erc20_address: felt
    ) {
        Ownable.initializer(owner);
        erc20_address_.write(erc20_address);
        return ();
    }

    // ------
    // EXTERNAL FUNCTIONS
    // ------

    //##
    // Creates a new vesting for a beneficiary.
    // @param beneficiary address of the beneficiary to whom vested tokens are transferred
    // @param _start start time of the vesting period
    // @param cliff_delta duration in seconds of the cliff in which tokens will begin to vest
    // @param duration duration in seconds of the period in which the tokens will vest
    // @param slice_period_seconds duration of a slice period for the vesting in seconds
    // @param revocable whether the vesting is revocable or not
    // @param amount_total total amount of tokens to be released at the end of the vesting
    //##
    func create_vesting{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        beneficiary: felt,
        cliff_delta: felt,
        start: felt,
        duration: felt,
        slice_period_seconds: felt,
        revocable: felt,
        amount_total: Uint256,
    ) -> (vesting_id: felt) {
        alloc_locals;
        // Access control check
        Ownable.assert_only_owner();

        // cliff_delta is expressed as a delta compared to start
        // cliff is the timestamp after which the cliff period ends
        // At cliff + 1 second it is possible to claim vested tokens
        let cliff = start + cliff_delta;

        // Check parameters preconditions
        new_vesting_check_preconditions(
            beneficiary, cliff, start, duration, slice_period_seconds, revocable, amount_total
        );

        // Get the number of available tokens
        let (available_amount) = withdrawable_amount();
        // Check if the contract owns sufficient tokens to pay the entire vesting
        let (has_enough_available_tokens) = uint256_le(amount_total, available_amount);
        with_attr error_message("StarkVest: not enough available tokens") {
            assert has_enough_available_tokens = TRUE;
        }

        // Get current vesting count for beneficiary
        let (vesting_count) = vesting_count_.read(beneficiary);
        // Compute the next vesting id
        let (vesting_id) = compute_vesting_id(beneficiary, vesting_count);
        local syscall_ptr: felt* = syscall_ptr;
        // Increment vesting count for beneficiary
        increment_vesting_count(beneficiary);
        // Init vesting struct
        let (vesting) = init_vesting(
            beneficiary, cliff, start, duration, slice_period_seconds, revocable, amount_total
        );

        // Write Vesting struct in storage
        vestings_.write(vesting_id, vesting);

        // Update vestings total amount
        let (vestings_total_amount) = vestings_total_amount_.read();
        let (new_vestings_total_amount) = SafeUint256.add(vestings_total_amount, amount_total);
        vestings_total_amount_.write(new_vestings_total_amount);

        // Emit event
        VestingCreated.emit(beneficiary, amount_total, vesting_id);

        return (vesting_id,);
    }

    //##
    // Revokes the vesting identified by vesting_id.
    // @param vesting_id the vesting identifier
    // @return the amount of releasable tokens
    //##
    func revoke{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(vesting_id: felt) {
        alloc_locals;
        // Access control check
        Ownable.assert_only_owner();
        // Check vesting id
        internal.assert_valid_vesting_id(vesting_id);
        // Get the vesting from storage
        let (vesting) = vestings_.read(vesting_id);
        // Check that vesting is revocable
        internal.assert_revocable(vesting);

        // Release releasable tokens
        let (releasable_amount) = _releasable_amount(vesting);
        release_if_tokens_releasable(vesting_id, releasable_amount);

        // Get the vesting from storage
        let (vesting) = vestings_.read(vesting_id);

        // Update vestings total_amount
        let (unreleased_tokens) = SafeUint256.sub_le(vesting.amount_total, vesting.released);
        let (vestings_total_amount) = vestings_total_amount_.read();
        let (new_vestings_total_amount) = SafeUint256.sub_le(
            vestings_total_amount, unreleased_tokens
        );
        vestings_total_amount_.write(new_vestings_total_amount);

        // Update vesting
        let vesting = Vesting(
            vesting.beneficiary,
            vesting.cliff,
            vesting.start,
            vesting.duration,
            vesting.slice_period_seconds,
            vesting.revocable,
            vesting.amount_total,
            vesting.released,
            TRUE,
        );
        // Save updated vesting
        vestings_.write(vesting_id, vesting);
        // Emit event
        VestingRevoked.emit(vesting_id);
        return ();
    }

    func release_if_tokens_releasable{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(vesting_id: felt, amount: Uint256) {
        let (has_tokens_to_release) = uint256_lt(Uint256(0, 0), amount);
        if (has_tokens_to_release == TRUE) {
            release(vesting_id, amount);
            return ();
        }
        return ();
    }

    //##
    // Release vested amount of tokens.
    // @param vesting_id the vesting identifier
    // @param amount the amount to release
    //##
    func release{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        vesting_id: felt, amount: Uint256
    ) {
        alloc_locals;
        // Start reetrancy guard
        ReentrancyGuard.start();

        // Get vesting
        let (vesting) = internal.get_vesting_and_assert_exist(vesting_id);

        // Access control check
        // Caller must be owner or beneficiary
        let (caller) = get_caller_address();
        let (owner) = Ownable.owner();
        let (is_owner) = internal.are_equal(caller, owner);
        let (is_beneficiary) = internal.are_equal(caller, vesting.beneficiary);
        let owner_or_beneficiary = is_owner + is_beneficiary;
        with_attr error_message("StarkVest: only beneficiary and owner can release vested tokens") {
            assert_not_zero(owner_or_beneficiary);
        }
        let beneficiary = vesting.beneficiary;

        // Check that account has enough releasable tokens
        let (releasable_amount) = _releasable_amount(vesting);
        with_attr error_message(
                "StarkVest: cannot release tokens, not enough vested releasable tokens") {
            uint256_le(amount, releasable_amount);
        }

        // Update vesting
        let (new_amount_released) = SafeUint256.add(vesting.released, amount);
        let vesting = Vesting(
            vesting.beneficiary,
            vesting.cliff,
            vesting.start,
            vesting.duration,
            vesting.slice_period_seconds,
            vesting.revocable,
            vesting.amount_total,
            new_amount_released,
            vesting.revoked,
        );
        // Save updated vesting
        vestings_.write(vesting_id, vesting);

        // Update vestings total amount
        // Subtract the released amount from the total
        let (vestings_total_amount) = vestings_total_amount_.read();
        let (new_vestings_total_amount) = SafeUint256.sub_le(vestings_total_amount, amount);
        vestings_total_amount_.write(new_vestings_total_amount);

        // Do the transfer of released tokens to the benficiary
        let (erc20_address) = erc20_address_.read();
        let (contract_address) = get_contract_address();
        let (transfer_success) = IERC20.transfer(erc20_address, beneficiary, amount);

        // Assert transfer success
        with_attr error_message("StarkVest: transfer of released tokens failed") {
            assert transfer_success = TRUE;
        }

        // Emit event
        TokensReleased.emit(vesting_id, amount);

        // End reetrancy guard
        ReentrancyGuard.end();
        return ();
    }

    //##
    // Witdraw an amount of tokens from the vesting contract.
    // @param amount the amount to withdraw
    //##
    func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        amount: Uint256
    ) {
        alloc_locals;
        // Access control check
        Ownable.assert_only_owner();

        // Start reetrancy guard
        ReentrancyGuard.start();

        // Get withdrawable amount
        let (_withdrawable_amount) = withdrawable_amount();

        // Check if enough tokens available
        with_attr error_message(
                "StarkVest: cannot withdraw tokens, not enough withdrawable tokens") {
            let (is_le) = uint256_le(amount, _withdrawable_amount);
            assert is_le = TRUE;
        }

        // Do the transfer to the owner
        let (owner) = Ownable.owner();
        let (erc20_address) = erc20_address_.read();
        let (transfer_success) = IERC20.transfer(erc20_address, owner, amount);

        // Assert transfer success
        with_attr error_message("StarkVest: withdraw tokens failed") {
            assert transfer_success = TRUE;
        }

        // End reetrancy guard
        ReentrancyGuard.end();
        return ();
    }

    //##
    // Compute vesting_id for a given account and vesting_count.
    // @param account the account linked to the vesting
    // @param vesting_count the current number of vestings associated to the account
    //##
    func compute_vesting_id{pedersen_ptr: HashBuiltin*}(account: felt, vesting_count: felt) -> (
        vesting_id: felt
    ) {
        let vesting_id = account;
        let (vesting_id) = hash2{hash_ptr=pedersen_ptr}(vesting_id, vesting_count);
        return (vesting_id=vesting_id);
    }

    // ------
    // INTERNAL FUNCTIONS
    // ------

    //##
    // Get releasable amount of tokens for a vesting
    //##
    func _releasable_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        vesting: Vesting
    ) -> (releasable_amount: Uint256) {
        alloc_locals;
        // Get current timestamp
        let (current_time) = get_block_timestamp();
        // Check if we are before the cliff
        let before_cliff = is_le(current_time, vesting.cliff);
        // Check if revoked
        let is_revoked = vesting.revoked;
        let sum = before_cliff + is_revoked;
        let before_cliff_or_is_revoked = is_not_zero(sum);
        // Either we are before the cliff or the vesting is revoked
        // In both cases the amount of releasable tokens is 0
        if (before_cliff_or_is_revoked == TRUE) {
            let vested_amount = Uint256(0, 0);
            return (vested_amount,);
        }

        // Compute vesting end timestamp
        let vesting_end_time = vesting.start + vesting.duration;
        let after_vesting_end = is_le(vesting_end_time, current_time);

        // Vesting is over
        // Return total minus what has already been released
        if (after_vesting_end == TRUE) {
            let (releasable_amount) = SafeUint256.sub_lt(vesting.amount_total, vesting.released);
            return (releasable_amount,);
        }

        // Compute how much time we are past the start of vesting
        let time_from_start = current_time - vesting.start;
        // Get the number of seconds per vesting period
        let seconds_per_slice = vesting.slice_period_seconds;
        // Compute how many periods have been vested
        // We can ignore the remainder here
        let (vested_periods, _) = unsigned_div_rem(time_from_start, seconds_per_slice);
        // The final vested seconds is the number of vested periods multiplied by the number of seconds per period
        // Cast it as a Uint256 to do math operations with tokens amount which are experessed as Uint256
        let final_vested_seconds = Uint256(vested_periods * seconds_per_slice, 0);
        // Cast duration as Uint256 as well
        let vesting_duration_uint256 = Uint256(vesting.duration, 0);
        let (tmp_amount) = SafeUint256.mul(vesting.amount_total, final_vested_seconds);
        let (vested_amount, _) = SafeUint256.div_rem(tmp_amount, vesting_duration_uint256);
        // Substract released tokens
        let (releasable_amount) = SafeUint256.sub_lt(vested_amount, vesting.released);
        return (releasable_amount,);
    }

    //##
    // Checks conditions on vesting parameters.
    //##
    func new_vesting_check_preconditions{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(
        beneficiary: felt,
        cliff: felt,
        start: felt,
        duration: felt,
        slice_period_seconds: felt,
        revocable: felt,
        amount_total: Uint256,
    ) {
        internal.assert_valid_timestamp(cliff);
        internal.assert_valid_timestamp(start);
        internal.assert_valid_timestamp(duration);
        internal.assert_valid_timestamp(slice_period_seconds);

        let vesting_end_timestamp = start + duration;
        // vesting cannot end after January 1, 3000
        internal.assert_valid_timestamp(vesting_end_timestamp);

        // Check beneficiary address
        with_attr error_message("StarkVest: cannot set the beneficiary to zero address") {
            assert_not_zero(beneficiary);
        }

        // Check duration
        with_attr error_message("StarkVest: Duration must be > 0") {
            assert_not_zero(duration);
            assert_nn(duration);
        }

        // Check slice period seconds
        with_attr error_message(
                "StarkVest: Slice period seconds must be between 1 and MAX_SLICE_PERIOD_SECONDS") {
            assert_in_range(slice_period_seconds, 1, MAX_SLICE_PERIOD_SECONDS);
        }
        return ();
    }

    //##
    // Increment the vesting count for a given account.
    // @param account the account
    //##
    func increment_vesting_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        account: felt
    ) {
        let (vesting_count) = vesting_count_.read(account);
        let vesting_count = vesting_count + 1;
        vesting_count_.write(account, vesting_count);
        return ();
    }

    //##
    // Initialize Vesting struct
    //##
    func init_vesting(
        beneficiary: felt,
        cliff: felt,
        start: felt,
        duration: felt,
        slice_period_seconds: felt,
        revocable: felt,
        amount_total: Uint256,
    ) -> (vesting: Vesting) {
        alloc_locals;
        local vesting: Vesting;
        assert vesting.beneficiary = beneficiary;
        assert vesting.cliff = cliff;
        assert vesting.start = start;
        assert vesting.duration = duration;
        assert vesting.slice_period_seconds = slice_period_seconds;
        assert vesting.revocable = revocable;
        assert vesting.amount_total = amount_total;
        assert vesting.released = Uint256(0, 0);
        assert vesting.revoked = FALSE;
        return (vesting=vesting);
    }
}

namespace internal {
    func get_vesting_and_assert_exist{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(vesting_id: felt) -> (vesting: Vesting) {
        let (vesting) = vestings_.read(vesting_id);
        with_attr error_message("StarkVest: vesting does not exist") {
            assert_not_zero(vesting.beneficiary);
        }
        return (vesting=vesting);
    }

    func are_equal(a: felt, b: felt) -> (res: felt) {
        if (a == b) {
            return (res=TRUE);
        }
        return (res=FALSE);
    }

    func assert_valid_timestamp{range_check_ptr}(value: felt) {
        with_attr error_message(
                "StarkVest: value is not a valid timestamp in the context of StarkVest") {
            assert_in_range(value, 0, MAX_TIMESTAMP);
        }
        return ();
    }

    func assert_valid_vesting_id(vesting_id: felt) {
        with_attr error_message("StarkVest: not a valid vesting id") {
            assert_not_zero(vesting_id);
        }
        return ();
    }
    func assert_revocable(vesting: Vesting) {
        with_attr error_message("StarkVest: vesting is not revocable") {
            assert vesting.revocable = TRUE;
        }
        return ();
    }
}
