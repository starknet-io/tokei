// SPDX-License-Identifier: MIT
// StarkVest Contracts for Cairo v0.1.0 (test_nominal_case.cairo)

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_timestamp

// OpenZeppelin dependencies
from openzeppelin.token.erc20.IERC20 import IERC20

// Project dependencies
from interfaces.starkvest import IStarkVest
from starkvest.model import Vesting

const ADMIN = 'starkvest-admin';
const USER_1 = 'user-1';
const TOKEN_NAME = 'StarkVestToken';
const TOKEN_SYMBOL = 'SVT';
const TOKEN_DECIMALS = 6;
const TOKEN_INITIAL_SUPPLY_LO = 1000000;
const TOKEN_INITIAL_SUPPLY_HI = 0;

//
// Functions
//

@view
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar payment_token_contract;
    tempvar starkvest_contract;
    %{
        # Payment token deployment
        ids.payment_token_contract = deploy_contract(
            "./tests/mocks/erc20.cairo",
            {
                "name": ids.TOKEN_NAME,
                "symbol": ids.TOKEN_SYMBOL,
                "decimals": ids.TOKEN_DECIMALS,
                "initial_supply": ids.TOKEN_INITIAL_SUPPLY_LO,
                "recipient": ids.ADMIN
            },
        ).contract_address
        context.payment_token_contract = ids.payment_token_contract

        # Starkvest deployment
        ids.starkvest_contract = deploy_contract(
            "./src/starkvest/starkvest.cairo",
            {
                "owner": ids.ADMIN,
                "erc20_address": ids.payment_token_contract
            },
        ).contract_address
        context.starkvest_contract = ids.starkvest_contract
    %}

    %{ stop_pranks = [start_prank(ids.ADMIN, contract) for contract in [ids.starkvest_contract, ids.payment_token_contract] ] %}
    // Setup contracts with admin account
    %{ [stop_prank() for stop_prank in stop_pranks] %}

    return ();
}

namespace payment_token_instance {
    // Internals

    func deployed() -> (payment_token_contract: felt) {
        tempvar payment_token_contract;
        %{ ids.payment_token_contract = context.payment_token_contract %}
        return (payment_token_contract,);
    }

    // Views

    func balanceOf{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, payment_token: felt
    }(account: felt) -> (balance: Uint256) {
        let (balance) = IERC20.balanceOf(payment_token, account);
        return (balance,);
    }

    func allowance{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, payment_token: felt
    }(owner: felt, spender: felt) -> (remaining: Uint256) {
        let (remaining) = IERC20.allowance(payment_token, owner, spender);
        return (remaining,);
    }

    // Externals

    func approve{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, payment_token: felt
    }(spender: felt, amount: Uint256) -> (success: felt) {
        %{ stop_prank = start_prank(caller_address=ids.ADMIN, target_contract_address=ids.payment_token) %}
        let (success) = IERC20.approve(payment_token, spender, amount);
        %{ stop_prank() %}
        return (success,);
    }

    func transfer{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, payment_token: felt
    }(recipient: felt, amount: Uint256) -> (success: felt) {
        %{ stop_prank = start_prank(caller_address=ids.ADMIN, target_contract_address=ids.payment_token) %}
        let (success) = IERC20.transfer(payment_token, recipient, amount);
        %{ stop_prank() %}
        return (success,);
    }
}

namespace starkvest_instance {
    // Internals

    func deployed() -> (starkvest_contract: felt) {
        tempvar starkvest_contract;
        %{ ids.starkvest_contract = context.starkvest_contract %}
        return (starkvest_contract,);
    }

    func create_vesting{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, starkvest: felt
    }(
        beneficiary: felt,
        cliff_delta: felt,
        start: felt,
        duration: felt,
        slice_period_seconds: felt,
        revocable: felt,
        amount_total: Uint256,
    ) -> (vesting_id: felt) {
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
        );
        %{ stop_prank() %}
        return (vesting_id,);
    }

    func releasable_amount{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, starkvest: felt
    }(vesting_id: felt) -> (releasable_amount: Uint256) {
        let (releasable_amount) = IStarkVest.releasable_amount(starkvest, vesting_id);
        return (releasable_amount,);
    }

    func revoke{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, starkvest: felt}(
        vesting_id: felt
    ) {
        %{ stop_prank = start_prank(ids.ADMIN, ids.starkvest) %}
        IStarkVest.revoke(starkvest, vesting_id);
        %{ stop_prank() %}
        return ();
    }

    func release{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, starkvest: felt}(
        vesting_id: felt, amount: Uint256
    ) {
        %{ stop_prank = start_prank(ids.ADMIN, ids.starkvest) %}
        IStarkVest.release(starkvest, vesting_id, amount);
        %{ stop_prank() %}
        return ();
    }

    func vestings_total_amount{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, starkvest: felt
    }() -> (vestings_total_amount: Uint256) {
        let (vestings_total_amount) = IStarkVest.vestings_total_amount(starkvest);
        return (vestings_total_amount,);
    }

    func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, starkvest: felt}(
        amount: Uint256
    ) {
        %{ stop_prank = start_prank(ids.ADMIN, ids.starkvest) %}
        IStarkVest.withdraw(starkvest, amount);
        %{ stop_prank() %}
        return ();
    }
}

@view
func test_e2e{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    // Get ERC20 token deployed contract instance
    let (payment_token) = payment_token_instance.deployed();
    // Get StarkVest deployed contract instance
    let (starkvest) = starkvest_instance.deployed();

    with payment_token {
        // ADMIN => STARKVEST : 2000 $SVT
        let (success) = payment_token_instance.transfer(
            starkvest, Uint256(2000, 0)
        );
        assert success = TRUE;
    }

    with starkvest {
        // Create vesting:
        // 1000 $SVT over 1 hour, with no cliff period
        // vested second by second, starting at timestamp: 1000
        let beneficiary = USER_1;
        let cliff_delta = 0;
        let start = 1000;
        let duration = 3600;
        let slice_period_seconds = 1;
        let revocable = TRUE;
        let amount_total = Uint256(1000, 0);
        %{ expect_events({"name": "VestingCreated"}) %}
        let (vesting_id) = starkvest_instance.create_vesting(
            beneficiary, cliff_delta, start, duration, slice_period_seconds, revocable, amount_total
        );

        // Set block time to 999 (1 second before vesting starts)
        %{ stop_warp = warp(999, ids.starkvest) %}
        let (releasable_amount) = starkvest_instance.releasable_amount(vesting_id);
        %{ stop_warp() %}
        assert releasable_amount = Uint256(0, 0);

        // Set block time to 2800 (1800 second after vesting starts)
        // Should have vested 50% of tokens
        %{ stop_warp = warp(2800, ids.starkvest) %}
        let (releasable_amount) = starkvest_instance.releasable_amount(vesting_id);
        assert releasable_amount = Uint256(500, 0);
    }

    with payment_token {
        // Check balance of vesting contract before release
        let (starkvest_balance) = payment_token_instance.balanceOf(starkvest);
        assert starkvest_balance = Uint256(2000, 0);

        // Check balance of user 1 before release
        let (user_1_balance) = payment_token_instance.balanceOf(USER_1);
        assert user_1_balance = Uint256(0, 0);
    }

    with starkvest {
        // Check vestings total amount before release
        let (vestings_total_amount) = starkvest_instance.vestings_total_amount();
        assert vestings_total_amount = Uint256(1000, 0);

        // Release 100 tokens
        starkvest_instance.release(vesting_id, Uint256(100, 0));
        let (releasable_amount) = starkvest_instance.releasable_amount(vesting_id);
        assert releasable_amount = Uint256(400, 0);
    }
    with payment_token{
        // Check balance of vesting contract after release
        let (starkvest_balance) = payment_token_instance.balanceOf(starkvest);
        assert starkvest_balance = Uint256(1900, 0);

        // Check balance of user 1 after release
        let (user_1_balance) = payment_token_instance.balanceOf(USER_1);
        assert user_1_balance = Uint256(100, 0);
    }
    with starkvest{
        // Check vestings total amount after release
        let (vestings_total_amount) = starkvest_instance.vestings_total_amount();
        assert vestings_total_amount = Uint256(900, 0);

        // Withdraw 1000
        starkvest_instance.withdraw(Uint256(1000, 0));
    }
    with payment_token{
        let (starkvest_balance) = payment_token_instance.balanceOf(starkvest);
        assert starkvest_balance = Uint256(900, 0);
        let (owner_balance) = payment_token_instance.balanceOf(ADMIN);
        assert owner_balance = Uint256(999000, 0);
    }
    // Revoke
    // The 400 remaining vested tokens should be released
    %{ expect_events({"name": "VestingRevoked", "data": [ids.vesting_id]}) %}
    %{ expect_events({"name": "TokensReleased", "data": [ids.vesting_id, 400, 0]}) %}
    with starkvest{
        starkvest_instance.revoke(vesting_id);
    }
    %{ stop_warp() %}

    with payment_token{
        // Check balance of user 1 after revoke
        let (user_1_balance) = payment_token_instance.balanceOf(USER_1);
        assert user_1_balance = Uint256(500, 0);
    }

    return ();
}
