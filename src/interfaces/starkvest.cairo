# SPDX-License-Identifier: MIT
# StarkVest Contracts for Cairo v0.0.1 (starkvest.cairo)

%lang starknet

@contract_interface
namespace IStarkVest:
    func erc20_address() -> (erc20_address : felt):
    end
end
