# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (test_nominal_case.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_timestamp

# OpenZeppelin dependencies
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

# Project dependencies
from interfaces.starkvest import IStarkVest
from starkvest.model import Vesting

const ADMIN = 'starkvest-admin'
const USER_1 = 'user-1'
const TOKEN_NAME = 'StarkVestToken'
const TOKEN_SYMBOL = 'SVT'
const TOKEN_DECIMALS = 6
const TOKEN_INITIAL_SUPPLY_LO = 1000000
const TOKEN_INITIAL_SUPPLY_HI = 0

@view
func __setup__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    tempvar token_contract
    tempvar starkvest_contract
    %{
        ids.token_contract = deploy_contract(
            "./tests/mocks/token/erc20.cairo", 
            [ids.TOKEN_NAME, ids.TOKEN_SYMBOL, ids.TOKEN_DECIMALS, ids.TOKEN_INITIAL_SUPPLY_LO, ids.TOKEN_INITIAL_SUPPLY_HI, ids.ADMIN]
        ).contract_address 
        context.token_contract = ids.token_contract

        ids.starkvest_contract = deploy_contract("./src/starkvest/starkvest.cairo", [ids.ADMIN, ids.token_contract]).contract_address 
        context.starkvest_contract = ids.starkvest_contract
    %}

    %{ stop_pranks = [start_prank(ids.ADMIN, contract) for contract in [ids.starkvest_contract, ids.token_contract] ] %}
    # Setup contracts with admin account
    %{ [stop_prank() for stop_prank in stop_pranks] %}

    return ()
end

@view
func test_e2e{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    # Get ERC20 token deployed contract instance
    let (token) = token_instance.deployed()
    # Get StarkVest deployed contract instance
    let (starkvest) = starkvest_instance.deployed()

    # ADMIN => STARKVEST : 2000 $SVT
    %{ stop_prank = start_prank(ids.ADMIN, ids.token) %}
    IERC20.transfer(token, starkvest, Uint256(2000, 0))
    %{ stop_prank() %}

    with starkvest:
        # Create vesting:
        # 1000 $SVT over 1 hour, with no cliff period
        # vested second by second, starting at timestamp: 1000
        let beneficiary = USER_1
        let cliff_delta = 0
        let start = 1000
        let duration = 3600
        let slice_period_seconds = 1
        let revocable = TRUE
        let amount_total = Uint256(1000, 0)
        %{ expect_events({"name": "VestingCreated"}) %}
        let (vesting_id) = starkvest_instance.create_vesting(
            beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
        )

        # Set block time to 999 (1 second before vesting starts)
        %{ stop_warp = warp(999, ids.starkvest) %}
        let (releasable_amount) = starkvest_instance.releaseable_amount(vesting_id)
        %{ stop_warp() %}
        assert releasable_amount = Uint256(0, 0)

        # Set block time to 2800 (1800 second after vesting starts)
        # Should have vested 50% of tokens
        %{ stop_warp = warp(2800, ids.starkvest) %}
        let (releasable_amount) = starkvest_instance.releaseable_amount(vesting_id)
        assert releasable_amount = Uint256(500, 0)

        # Check balance of vesting contract before release
        let (starkvest_balance) = IERC20.balanceOf(token, starkvest)
        assert starkvest_balance = Uint256(2000, 0)

        # Check balance of user 1 before release
        let (user_1_balance) = IERC20.balanceOf(token, USER_1)
        assert user_1_balance = Uint256(0, 0)

        # Check vestings total amount before release
        let (vestings_total_amount) = starkvest_instance.vestings_total_amount()
        assert vestings_total_amount = Uint256(1000, 0)

        # Release 100 tokens
        starkvest_instance.release(vesting_id, Uint256(100, 0))
        let (releasable_amount) = starkvest_instance.releaseable_amount(vesting_id)
        %{ stop_warp() %}
        assert releasable_amount = Uint256(400, 0)

        # Check balance of vesting contract after release
        let (starkvest_balance) = IERC20.balanceOf(token, starkvest)
        assert starkvest_balance = Uint256(1900, 0)

        # Check balance of user 1 after release
        let (user_1_balance) = IERC20.balanceOf(token, USER_1)
        assert user_1_balance = Uint256(100, 0)

        # Check vestings total amount after release
        let (vestings_total_amount) = starkvest_instance.vestings_total_amount()
        assert vestings_total_amount = Uint256(900, 0)
    end

    return ()
end

namespace starkvest_instance:
    func deployed() -> (starkvest_contract : felt):
        tempvar starkvest_contract
        %{ ids.starkvest_contract = context.starkvest_contract %}
        return (starkvest_contract)
    end

    func create_vesting{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, starkvest : felt
    }(
        beneficiary : felt,
        cliff_delta : felt,
        start : felt,
        duration : felt,
        slice_period_seconds : felt,
        revocable : felt,
        amount_total : Uint256,
    ) -> (vesting_id : felt):
        %{ stop_prank = start_prank(ids.ADMIN, ids.starkvest) %}
        let (vesting_id) = IStarkVest.create_vesting(
            starkvest,
            beneficiary,
            cliff_delta,
            start,
            duration,
            slice_period_seconds,
            revocable,
            amount_total,
        )
        %{ stop_prank() %}
        return (vesting_id)
    end

    func releaseable_amount{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, starkvest : felt
    }(vesting_id : felt) -> (releaseable_amount : Uint256):
        let (releaseable_amount) = IStarkVest.releaseable_amount(starkvest, vesting_id)
        return (releaseable_amount)
    end

    func revoke{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, starkvest : felt
    }(vesting_id : felt):
        %{ stop_prank = start_prank(ids.ADMIN, ids.starkvest) %}
        IStarkVest.revoke(starkvest, vesting_id)
        %{ stop_prank() %}
        return ()
    end

    func release{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, starkvest : felt
    }(vesting_id : felt, amount : Uint256):
        %{ stop_prank = start_prank(ids.ADMIN, ids.starkvest) %}
        IStarkVest.release(starkvest, vesting_id, amount)
        %{ stop_prank() %}
        return ()
    end

    func vestings_total_amount{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, starkvest : felt
    }() -> (vestings_total_amount : Uint256):
        let (vestings_total_amount) = IStarkVest.vestings_total_amount(starkvest)
        return (vestings_total_amount)
    end
end

namespace token_instance:
    func deployed() -> (token_contract : felt):
        tempvar token_contract
        %{ ids.token_contract = context.token_contract %}
        return (token_contract)
    end
end
