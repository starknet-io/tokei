# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (starkvest.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IStarkVest:
    ###
    # Compute and return releaseable amount of tokens for a vesting.
    # @param vesting_id the vesting identifier
    # @return the amount of releaseable tokens
    ###
    func releaseable_amount(vesting_id : felt) -> (releaseable_amount : Uint256):
    end

    ###
    # @return the total amount locked in vestings
    ###
    func vestings_total_amount() -> (vestings_total_amount : Uint256):
    end

    ###
    # Compute and return the amount of tokens withdrawable by the owner.
    # @return the amount of withdrawable tokens
    ###
    func withdrawable_amount() -> (releaseable_amount : Uint256):
    end

    ###
    # Revokes the vesting identified by vesting_id.
    # @param vesting_id the vesting identifier
    # @return the amount of releaseable tokens
    ###
    func revoke(vesting_id : felt):
    end

    ###
    # Release vested amount of tokens.
    # @param vesting_id the vesting identifier
    # @param amount the amount to release
    ###
    func release(vesting_id : felt, amount : Uint256):
    end

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
    func create_vesting(
        beneficiary : felt,
        cliff_delta : felt,
        start : felt,
        duration : felt,
        slice_period_seconds : felt,
        revocable : felt,
        amount_total : Uint256,
    ) -> (vesting_id : felt):
    end

    ###
    # Witdraw an amount of tokens from the vesting contract.
    # @param amount the amount to withdraw
    ###
    func withdraw(amount : Uint256):
    end
end
