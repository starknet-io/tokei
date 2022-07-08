# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (libary.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_le
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import (
    assert_not_zero,
    assert_nn,
    assert_le,
    assert_in_range,
    unsigned_div_rem,
)
from starkware.cairo.common.math_cmp import is_le, is_nn
from starkware.starknet.common.syscalls import get_contract_address, get_block_timestamp

# OpenZeppelin dependencies
from openzeppelin.access.ownable import Ownable
from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

# Project dependencies

from starkvest.model import Vesting, MAX_SLICE_PERIOD_SECONDS, MAX_TIMESTAMP
from starkvest.events import VestingCreated

# ------
# STORAGE
# ------

# Address of the ERC20 token.
@storage_var
func erc20_address_() -> (erc20_address : felt):
end

# Amount of tokens currently locked in vestings.
@storage_var
func vestings_total_amount_() -> (vesting_total_amount : Uint256):
end

# Number of vesting per beneficiary address.
@storage_var
func vesting_count_(account : felt) -> (vesting_count : felt):
end

# Mapping of vestings
@storage_var
func vestings_(vesting_id : felt) -> (vesting : Vesting):
end

namespace StarkVest:
    # ------
    # VIEWS
    # ------

    ###
    # Returns the address of the ERC20 token managed by the vesting contract.
    ###
    func erc20_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        erc20_address : felt
    ):
        return erc20_address_.read()
    end

    ###
    # Returns the total amount of tokens currently locked in vestings.
    ###
    func vestings_total_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (vestings_total_amount : Uint256):
        let (vestings_total_amount) = vestings_total_amount_.read()
        return (vestings_total_amount)
    end

    ###
    # Returns the number of vestings associated to a beneficiary.
    ###
    func vesting_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (vesting_count : felt):
        let (vesting_count) = vesting_count_.read(account)
        return (vesting_count)
    end

    ###
    # Get a vesting for a specified id.
    # @param vesting_id the identifier of the vesting
    ###
    func vestings{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        vesting_id : felt
    ) -> (vesting : Vesting):
        let (vesting) = vestings_.read(vesting_id)
        return (vesting)
    end

    ###
    # Returns the amount of tokens that can be withdrawn by the owner.
    # This can also be used to determine the number of tokens usable to create vestings.
    ###
    func withdrawable_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (withdrawable_amount : Uint256):
        let (contract_balance) = get_contract_balance()
        let (vestings_total_amount) = vestings_total_amount_.read()
        let (withdrawable_amount) = SafeUint256.sub_le(contract_balance, vestings_total_amount)
        return (withdrawable_amount)
    end

    ###
    # Get current contract balance.
    ###
    func get_contract_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (balance : Uint256):
        let (erc20_address) = erc20_address_.read()
        let (contract_address) = get_contract_address()
        let (balance) = IERC20.balanceOf(erc20_address, contract_address)
        return (balance)
    end

    ###
    # Get releaseable amount of tokens for a vesting
    ###
    func releaseable_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        vesting_id : felt
    ) -> (releaseable_amount : Uint256):
        let (vesting) = vestings_.read(vesting_id)
        with_attr error_message("StarkVest: invalid beneficiary"):
            assert_not_zero(vesting.beneficiary)
        end
        let (releaseable_amount) = _releaseable_amount(vesting)
        return (releaseable_amount)
    end

    # ------
    # CONSTRUCTOR
    # ------
    func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, erc20_address : felt
    ):
        Ownable.initializer(owner)
        erc20_address_.write(erc20_address)
        return ()
    end

    # ------
    # EXTERNAL FUNCTIONS
    # ------

    ###
    # Creates a new vesting for a beneficiary.
    # @param beneficiary address of the beneficiary to whom vested tokens are transferred
    # @param _start start time of the vesting period
    # @param cliff_delta duration in seconds of the cliff in which tokens will begin to vest
    # @param duration duration in seconds of the period in which the tokens will vest
    # @param slice_period_seconds duration of a slice period for the vesting in seconds
    # @param revocable whether the vesting is revocable or not
    # @param amount_total total amount of tokens to be released at the end of the vesting
    ###
    func create_vesting{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        beneficiary : felt,
        cliff_delta : felt,
        start : felt,
        duration : felt,
        slice_period_seconds : felt,
        revocable : felt,
        amount_total : Uint256,
    ) -> (vesting_id : felt):
        alloc_locals
        # Access control check
        Ownable.assert_only_owner()

        # cliff_delta is expressed as a delta compared to start
        # cliff is the timestamp after which the cliff period ends
        # At cliff + 1 second it is possible to claim vested tokens
        let cliff = start + cliff_delta

        # Check parameters preconditions
        new_vesting_check_preconditions(
            beneficiary, cliff, start, duration, slice_period_seconds, revocable, amount_total
        )

        # Get the number of available tokens
        let (available_amount) = withdrawable_amount()
        # Check if the contract owns sufficient tokens to pay the entire vesting
        let (has_enough_available_tokens) = uint256_le(amount_total, available_amount)
        with_attr error_message("StarkVest: not enough available tokens"):
            assert has_enough_available_tokens = TRUE
        end

        # Get current vesting count for beneficiary
        let (vesting_count) = vesting_count_.read(beneficiary)
        # Compute the next vesting id
        let (vesting_id) = compute_vesting_id(beneficiary, vesting_count)
        local syscall_ptr : felt* = syscall_ptr
        # Increment vesting count for beneficiary
        increment_vesting_count(beneficiary)
        # Init vesting struct
        let (vesting) = init_vesting(
            beneficiary, cliff, start, duration, slice_period_seconds, revocable, amount_total
        )

        # Write Vesting struct in storage
        vestings_.write(vesting_id, vesting)

        # Emit event
        VestingCreated.emit(beneficiary, amount_total, vesting_id)

        return (vesting_id)
    end

    # ------
    # INTERNAL FUNCTIONS
    # ------

    ###
    # Get releaseable amount of tokens for a vesting
    ###
    func _releaseable_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        vesting : Vesting
    ) -> (releaseable_amount : Uint256):
        # Get current timestamp
        let (current_time) = get_block_timestamp()
        # Check if we are before the cliff
        let (before_cliff) = is_le(current_time, vesting.cliff)
        # Check if revoked
        let (is_revoked) = vesting.is_revoked
        let (before_cliff_or_is_revoked) = before_cliff + is_revoked
        # Either we are before the cliff or the vesting is revoked
        # In both cases the amount of releaseable tokens is 0
        if is_nn(before_cliff_or_is_revoked) == TRUE:
            return (0)
        end

        # Compute vesting end timestamp
        let (vesting_end_time) = vesting.start + vesting.duration
        let (after_vesting_end) = is_le(vesting_end_time, current_time)

        # Vesting is over
        # Return total minus what has already been released
        if after_vesting_end == TRUE:
            let (releaseable_amount) = vesting.amount_total - vesting.released
            return (releaseable_amount)
        end

        # Compute how much time we are past the start of vesting
        let (time_from_start) = current_time - vesting.start
        # Get the number of seconds per vesting period
        let (seconds_per_slice) = vesting.slice_period_seconds
        # Compute how many periods have been vested
        # We can ignore the remainder here
        let (vested_periods, _) = unsigned_div_rem(time_from_start, seconds_per_slice)
        # The final vested seconds is the number of vested periods multiplied by the number of seconds per period
        let (final_vested_seconds) = vested_periods * seconds_per_slice

        let (tmp_amount) = vesting.amount_total * final_vested_seconds
        let (vested_amount, _) = unsigned_div_rem(tmp_amount, vesting.duration)
        return (vested_amount)
    end

    ###
    # Checks conditions on vesting parameters.
    ###
    func new_vesting_check_preconditions{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(
        beneficiary : felt,
        cliff : felt,
        start : felt,
        duration : felt,
        slice_period_seconds : felt,
        revocable : felt,
        amount_total : Uint256,
    ):
        internal.assert_valid_timestamp(cliff)
        internal.assert_valid_timestamp(start)
        internal.assert_valid_timestamp(duration)
        internal.assert_valid_timestamp(slice_period_seconds)

        let vesting_end_timestamp = start + duration
        # vesting cannot end after January 1, 3000
        internal.assert_valid_timestamp(vesting_end_timestamp)

        # Check beneficiary address
        with_attr error_message("StarkVest: cannot set the beneficiary to zero address"):
            assert_not_zero(beneficiary)
        end

        # Check duration
        with_attr error_message("StarkVest: Duration must be > 0"):
            assert_not_zero(duration)
            assert_nn(duration)
        end

        # Check slice period seconds
        with_attr error_message(
                "StarkVest: Slice period seconds must be between 1 and MAX_SLICE_PERIOD_SECONDS"):
            assert_in_range(slice_period_seconds, 1, MAX_SLICE_PERIOD_SECONDS)
        end
        return ()
    end

    ###
    # Increment the vesting count for a given account.
    # @param account the account
    ###
    func increment_vesting_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ):
        let (vesting_count) = vesting_count_.read(account)
        let vesting_count = vesting_count + 1
        vesting_count_.write(account, vesting_count)
        return ()
    end

    ###
    # Compute vesting_id for a given account and vesting_count.
    # @param account the account linked to the vesting
    # @param vesting_count the current number of vestings associated to the account
    ###
    func compute_vesting_id{pedersen_ptr : HashBuiltin*}(account : felt, vesting_count : felt) -> (
        vesting_id : felt
    ):
        let vesting_id = account
        let (vesting_id) = hash2{hash_ptr=pedersen_ptr}(vesting_id, vesting_count)
        return (vesting_id=vesting_id)
    end

    ###
    # Initialize Vesting struct
    ###
    func init_vesting(
        beneficiary : felt,
        cliff : felt,
        start : felt,
        duration : felt,
        slice_period_seconds : felt,
        revocable : felt,
        amount_total : Uint256,
    ) -> (vesting : Vesting):
        alloc_locals
        local vesting : Vesting
        assert vesting.beneficiary = beneficiary
        assert vesting.cliff = cliff
        assert vesting.start = start
        assert vesting.duration = duration
        assert vesting.slice_period_seconds = slice_period_seconds
        assert vesting.revocable = revocable
        assert vesting.amount_total = amount_total
        assert vesting.released = Uint256(0, 0)
        assert vesting.revoked = FALSE
        return (vesting=vesting)
    end
end

namespace internal:
    func assert_valid_timestamp{range_check_ptr}(value : felt):
        with_attr error_message(
                "StarkVest: value is not a valid timestamp in the context of StarkVest"):
            assert_in_range(value, 0, MAX_TIMESTAMP)
        end
        return ()
    end
end
