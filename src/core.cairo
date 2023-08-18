//! Main contract of Za Warudo protocol.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use core::traits::Into;
use starknet::{ContractAddress, ClassHash};

// *************************************************************************
//                  Interface of the `ZaWarudo` contract.
// *************************************************************************
#[starknet::interface]
trait IZaWarudo<TContractState> {
    /// Create a new stream.
    fn create_stream(ref self: TContractState,);
}

#[starknet::contract]
mod ZaWarudo {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************

    // Core lib imports.
    use core::result::ResultTrait;
    use starknet::{get_caller_address, ContractAddress, contract_address_const};
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;

    // Local imports.

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {}

    // *************************************************************************
    //                              CONSTRUCTOR
    // *************************************************************************

    /// Constructor of the contract..
    #[constructor]
    fn constructor(ref self: ContractState,) {}


    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl ZaWarudo of super::IZaWarudo<ContractState> {
        /// Create a new stream.
        fn create_stream(ref self: ContractState,) {}
    }
}
