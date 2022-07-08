# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (model.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.uint256 import Uint256

# Wednesday, January 1, 3000 1:00:00 GMT+01:00
# Ensure we can store timestamps with 35 bits
const MAX_TIMESTAMP = 32503680000

# 100,000 days
const MAX_SLICE_PERIOD_SECONDS = 8640000000

struct Vesting:
    # beneficiary of tokens after they are released
    member beneficiary : felt
    # end of cliff period in seconds
    member cliff : felt
    # start time of the vesting period
    member start : felt
    # duration of the vesting period in seconds
    member duration : felt
    # duration of a slice period for the vesting in seconds
    # example: for a hourly vesting slice_period_seconds must be set to 60 * 60
    member slice_period_seconds : felt
    # whether or not the vesting is revocable
    member revocable : felt
    # total amount of tokens to be released at the end of the vesting
    member amount_total : Uint256
    # amount of tokens released
    member released : Uint256
    # whether or not the vesting has been revoked
    member revoked : felt
end
