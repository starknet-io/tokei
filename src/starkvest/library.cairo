# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (libary.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_not_zero, assert_nn

# OpenZeppelin dependencies
from openzeppelin.access.ownable import Ownable

# Project dependencies

from starkvest.model import Vesting
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
func vesting_total_amount_() -> (vesting_total_amount : Uint256):
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
    func erc20_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        erc20_address : felt
    ):
        return erc20_address_.read()
    end

    func vesting_total_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (vesting_total_amount : Uint256):
        let (vesting_total_amount) = vesting_total_amount_.read()
        return (vesting_total_amount)
    end

    func vesting_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (vesting_count : felt):
        let (vesting_count) = vesting_count_.read(account)
        return (vesting_count)
    end

    func vestings{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        vesting_id : felt
    ) -> (vesting : Vesting):
        let (vesting) = vestings_.read(vesting_id)
        return (vesting)
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
    
    func create_vesting{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        beneficiary : felt,
        cliff : felt,
        start : felt,
        duration : felt,
        slicePeriodSeconds : felt,
        revocable : felt,
        amountTotal : Uint256,
    ) -> (vesting_id : felt):
        alloc_locals
        # Access control check
        Ownable.assert_only_owner()
        # Check preconditions
        new_vesting_check_preconditions(
            beneficiary, start, duration, slicePeriodSeconds, revocable, amountTotal
        )
        # Get current vesting count for beneficiary
        let (vesting_count) = vesting_count_.read(beneficiary)
        # Compute the next vesting id
        let (vesting_id) = compute_vesting_id(beneficiary, vesting_count)
        local syscall_ptr : felt* = syscall_ptr
        # Increment vesting count for beneficiary
        increment_vesting_count{syscall_ptr=syscall_ptr, pedersen_ptr=pedersen_ptr}(beneficiary)
        # Init vesting struct
        let (vesting) = init_vesting(
            beneficiary, cliff, start, duration, slicePeriodSeconds, revocable, amountTotal
        )

        # Write Vesting struct in storage
        vestings_.write(vesting_id, vesting)

        # Emit event
        VestingCreated.emit(beneficiary, amountTotal, vesting_id)

        return (vesting_id)
    end

    # ------
    # INTERNAL FUNCTIONS
    # ------

    func new_vesting_check_preconditions{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(
        beneficiary : felt,
        start : felt,
        duration : felt,
        slicePeriodSeconds : felt,
        revocable : felt,
        amountTotal : Uint256,
    ):
        with_attr error_message("StarkVest: cannot set the beneficiary to zero address"):
            assert_not_zero(beneficiary)
        end
        with_attr error_message("StarkVest: Duration must be > 0"):
            assert_not_zero(duration)
            assert_nn(duration)
        end
        return ()
    end

    func increment_vesting_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ):
        let (vesting_count) = vesting_count_.read(account)
        let vesting_count = vesting_count + 1
        vesting_count_.write(account, vesting_count)
        return ()
    end

    # Compute vesting_id for a given account and vesting_count
    func compute_vesting_id{pedersen_ptr : HashBuiltin*}(account : felt, vesting_count : felt) -> (
        vesting_id : felt
    ):
        let vesting_id = account
        let (vesting_id) = hash2{hash_ptr=pedersen_ptr}(vesting_id, vesting_count)
        return (vesting_id=vesting_id)
    end

    # Initialize Vesting struct
    func init_vesting(
        beneficiary : felt,
        cliff : felt,
        start : felt,
        duration : felt,
        slicePeriodSeconds : felt,
        revocable : felt,
        amountTotal : Uint256,
    ) -> (vesting : Vesting):
        alloc_locals
        local vesting : Vesting
        assert vesting.beneficiary = beneficiary
        assert vesting.cliff = cliff
        assert vesting.start = start
        assert vesting.duration = duration
        assert vesting.slicePeriodSeconds = slicePeriodSeconds
        assert vesting.revocable = revocable
        assert vesting.amountTotal = amountTotal
        assert vesting.released = Uint256(0, 0)
        assert vesting.revoked = FALSE
        return (vesting=vesting)
    end
end
