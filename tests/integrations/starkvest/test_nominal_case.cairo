# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (test_nominal_case.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256

# Project dependencies
from interfaces.starkvest import IStarkVest
from starkvest.model import Vesting

const ADMIN = 'starkvest-admin'
const VESTING_TOKEN_ADDRESS = 'vesting-token-address'

@view
func __setup__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    tempvar token_contract
    tempvar starkvest_contract
    # TODO: deploy ERC20 token and pass the address to starkvest constructor
    %{
        ids.starkvest_contract = deploy_contract("./src/starkvest/starkvest.cairo", [ids.ADMIN, ids.VESTING_TOKEN_ADDRESS]).contract_address 
        context.starkvest_contract = ids.starkvest_contract
    %}

    %{ stop_pranks = [start_prank(ids.ADMIN, contract) for contract in [ids.starkvest_contract] ] %}

    %{ [stop_prank() for stop_prank in stop_pranks] %}

    return ()
end

@view
func test_e2e{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (starkvest) = starkvest_instance.deployed()

    with starkvest:
        let (erc20_address) = starkvest_instance.erc20_address()
        assert erc20_address = VESTING_TOKEN_ADDRESS
    end

    return ()
end

namespace starkvest_instance:
    func deployed() -> (starkvest_contract : felt):
        tempvar starkvest_contract
        %{ ids.starkvest_contract = context.starkvest_contract %}
        return (starkvest_contract)
    end

    func erc20_address{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, starkvest : felt
    }() -> (erc20_address):
        let (erc20_address) = IStarkVest.erc20_address(starkvest)
        return (erc20_address)
    end
end
