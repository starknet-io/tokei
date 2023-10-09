//! Main contract of Tokei protocol.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use core::traits::Into;
use starknet::{ContractAddress, ClassHash};

// Local imports.
use tokei::types::lockup_linear::{Range, Broker};

//   ______ ____   __ __  ______ ____
//  /_  __// __ \ / //_/ / ____//  _/
//   / /  / / / // ,<   / __/   / /
//  / /  / /_/ // /| | / /___ _/ /
// /_/   \____//_/ |_|/_____//___/

//     __    ____   ______ __ __ __  __ ____
//    / /   / __ \ / ____// //_// / / // __ \
//   / /   / / / // /    / ,<  / / / // /_/ /
//  / /___/ /_/ // /___ / /| |/ /_/ // ____/
// /_____/\____/ \____//_/ |_|\____//_/

//     __     ____ _   __ ______ ___     ____
//    / /    /  _// | / // ____//   |   / __ \
//   / /     / / /  |/ // __/  / /| |  / /_/ /
//  / /___ _/ / / /|  // /___ / ___ | / _, _/
// /_____//___//_/ |_//_____//_/  |_|/_/ |_|

// *************************************************************************
//                  Interface of the `TokeiLockupLinear` contract.
// *************************************************************************
#[starknet::interface]
trait ITokeiLockupLinear<TContractState> {
    /// Create a new stream.
    /// # Arguments
    /// * `sender` - The address streaming the assets, with the ability to cancel the stream.
    /// * `recipient` - The address receiving the assets.
    /// * `total_amount` - The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
    /// fees, all denoted in units of the asset's decimals.
    /// * `asset` - The contract address of the ERC-20 asset used for streaming.
    /// * `cancelable` - Indicates if the stream is cancelable.
    /// * `range` - The range of the stream. Struct containing (i) the stream's start time, (ii) cliff time, and (iii) end time, all as Unix
    /// timestamps.
    /// * `broker` - The broker of the stream.  Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`.
    fn create_with_range(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        total_amount: u128,
        asset: ContractAddress,
        cancelable: bool,
        range: Range,
        broker: Broker,
    ) -> u64;
}

#[starknet::contract]
mod TokeiLockupLinear {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************

    // Core lib imports.
    use core::result::ResultTrait;
    use starknet::{
        get_caller_address, ContractAddress, contract_address_const, get_contract_address
    };
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;
    // Local imports.
    use tokei::types::lockup_linear::{Range, Broker, LockupLinearStream};
    use tokei::types::lockup::LockupAmounts;
    use tokei::tokens::erc721::{ERC721, IERC721};
    use tokei::libraries::helpers;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        admin: ContractAddress,
        next_stream_id: u64,
        streams: LegacyMap<u64, LockupLinearStream>,
    }

    // *************************************************************************
    // EVENTS
    // *************************************************************************

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        LockupLinearStreamCreated: LockupLinearStreamCreated,
    }


    #[derive(Drop, starknet::Event)]
    struct LockupLinearStreamCreated {
        stream_id: u64,
        funder: ContractAddress,
        sender: ContractAddress,
        recipient: ContractAddress,
        amounts: LockupAmounts,
        asset: ContractAddress,
        cancelable: bool,
        range: Range,
        broker: ContractAddress,
    }

    // *************************************************************************
    //                              CONSTRUCTOR
    // *************************************************************************

    /// Constructor of the contract.
    /// # Arguments
    /// * `initial_admin` - The initial admin of the contract.
    #[constructor]
    fn constructor(ref self: ContractState, initial_admin: ContractAddress) {
        // Set the initial admin.
        self.admin.write(initial_admin);

        // Set the next stream id.
        self.next_stream_id.write(1);

        // Initialize as ERC-721 contract.
        let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
        IERC721::initializer(
            ref state, 'Tokei Lockup Linear NFT', 'ZW-LOCKUP-LIN', get_contract_address()
        );
    }


    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl TokeiLockupLinear of super::ITokeiLockupLinear<ContractState> {
        /// Create a new stream.
        /// # Arguments
        /// * `sender` - The address streaming the assets, with the ability to cancel the stream.
        /// * `recipient` - The address receiving the assets.
        /// * `total_amount` - The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
        /// fees, all denoted in units of the asset's decimals.
        /// * `asset` - The contract address of the ERC-20 asset used for streaming.
        /// * `cancelable` - Indicates if the stream is cancelable.
        /// * `range` - The range of the stream. Struct containing (i) the stream's start time, (ii) cliff time, and (iii) end time, all as Unix
        /// timestamps.
        /// * `broker` - The broker of the stream.  Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
        /// percentage fee paid to the broker from `totalAmount`.
        fn create_with_range(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            total_amount: u128,
            asset: ContractAddress,
            cancelable: bool,
            range: Range,
            broker: Broker,
        ) -> u64 {
            // Safe Interactions: query the protocol fee. This is safe because it's a known Tokei contract that does
            // not call other unknown contracts.
            // TODO: implement.
            let protocol_fee = 0;

            // TODO: Handle MAX_FEE as a constant, with handlign of fixed point numbers.
            let MAX_FEE = 100;

            // Checks: check the fees and calculate the fee amounts.
            let create_amounts = helpers::check_and_calculate_fees(
                total_amount, protocol_fee, broker.fee, MAX_FEE
            );

            // Read the next stream id from storage.
            let stream_id = self.next_stream_id.read();

            // Checks: check the fees and calculate the fee amounts.
            // TODO: implement.
            let deposited_amount = total_amount - broker.fee;

            // Checks: validate the user-provided parameters.
            // TODO: implement.

            let amounts: LockupAmounts = LockupAmounts {
                deposited: deposited_amount, withdrawn: 0, refunded: 0,
            };

            // Effects: create the stream.
            let stream = LockupLinearStream {
                sender,
                asset,
                start_time: range.start,
                end_time: range.end,
                is_cancelable: cancelable,
                was_canceled: false,
                is_depleted: false,
                amounts,
            };
            self.streams.write(stream_id, stream);

            // Effects: bump the next stream id.
            self.next_stream_id.write(stream_id + 1);

            // Effects: mint the NFT to the recipient.
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::mint(ref state, recipient, stream_id.into());

            // Interactions: transfer the deposit and the protocol fee.
            // TODO: implement.

            // Interactions: pay the broker fee, if not zero.
            // TODO: implement.

            // Emit an event for  the newly created stream.
            self
                .emit(
                    LockupLinearStreamCreated {
                        stream_id,
                        funder: get_caller_address(),
                        sender,
                        recipient,
                        amounts,
                        asset,
                        cancelable,
                        range,
                        broker: broker.account,
                    }
                );

            // Return the stream id.
            stream_id
        }
    }

    #[external(v0)]
    impl TokeiLockupLinearERC721 of IERC721<ContractState> {
        fn initializer(
            ref self: ContractState, name_: felt252, symbol_: felt252, admin: ContractAddress
        ) {}

        fn balance_of(self: @ContractState, account: ContractAddress) -> u128 {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::balance_of(@state, account)
        }

        fn owner_of(self: @ContractState, token_id: u128) -> ContractAddress {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::owner_of(@state, token_id)
        }

        fn get_approved(self: @ContractState, token_id: u128) -> ContractAddress {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::get_approved(@state, token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::is_approved_for_all(@state, owner, operator)
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u128) {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::approve(ref state, to, token_id)
        }
        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::set_approval_for_all(ref state, operator, approved)
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u128
        ) {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::transfer_from(ref state, from, to, token_id)
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u128,
            data: Span<felt252>
        ) {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::safe_transfer_from(ref state, from, to, token_id, data)
        }

        fn mint(ref self: ContractState, to: ContractAddress, token_id: u128) {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::mint(ref state, to, token_id)
        }
    }
}
