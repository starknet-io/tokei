# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (model.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.uint256 import Uint256

struct Vesting:
    # beneficiary of tokens after they are released
    member beneficiary : felt
    # cliff period in seconds
    member cliff : felt
    # start time of the vesting period
    member start : felt
    # duration of the vesting period in seconds
    member duration : felt
    # duration of a slice period for the vesting in seconds
    member slicePeriodSeconds : felt
    # whether or not the vesting is revocable
    member revocable : felt
    # total amount of tokens to be released at the end of the vesting
    member amountTotal : Uint256
    # amount of tokens released
    member released : Uint256
    # whether or not the vesting has been revoked
    member revoked : felt
end
