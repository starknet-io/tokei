//! Main contract of Tokei protocol.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use core::traits::Into;
use starknet::{ContractAddress, ClassHash};

// Local imports.
use tokei::types::lockup_linear::{Range, Broker, LockupLinearStream, Durations};
use tokei::types::lockup::{Status};

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
    //////////////////////////////////////////////////////////////////////////
    //USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////

    /// Returns the asset address of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_asset(self: @TContractState, stream_id: u64) -> ContractAddress;

    /// Returns the cliff time of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_cliff_time(self: @TContractState, stream_id: u64) -> u64;

    /// Returns the deposited amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_deposited_amount(self: @TContractState, stream_id: u64) -> u128;

    /// Returns the end time of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_end_time(self: @TContractState, stream_id: u64) -> u64;

    /// Returns the Range of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_range(self: @TContractState, stream_id: u64) -> Range;

    /// Returns the refundable amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_refunded_amount(self: @TContractState, stream_id: u64) -> u128;

    /// Returns the sender address of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_sender(self: @TContractState, stream_id: u64) -> ContractAddress;

    /// Returns the start time of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_start_time(self: @TContractState, stream_id: u64) -> u64;

    /// Returns the stream state of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_stream(ref self: TContractState, stream_id: u64) -> LockupLinearStream;

    /// Returns the withdrawn amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_withdrawn_amount(self: @TContractState, stream_id: u64) -> u128;

    /// Returns if the stream is cancelable.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn is_cancelable(self: @TContractState, stream_id: u64) -> bool;

    /// Returns if the stream is transferable.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn is_transferable(self: @TContractState, stream_id: u64) -> bool;

    /// Returns if the stream is depleted.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn is_depleted(self: @TContractState, stream_id: u64) -> bool;

    /// Returns if the stream is canceled.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn is_stream(self: @TContractState, stream_id: u64) -> bool;

    /// Returns the refundable amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn refundable_amount_of(self: @TContractState, stream_id: u64) -> u128;

    /// Returns the recipient address of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_recipient(self: @TContractState, stream_id: u64) -> ContractAddress;

    /// Returns a bool if the stream was canceled, settled, or depleted.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn is_cold(self: @TContractState, stream_id: u64) -> bool;

    /// Returns a bool if the stream is streaming or pending.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn is_warm(self: @TContractState, stream_id: u64) -> bool;

    /// Returns the token URI of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn token_uri(self: @TContractState, token_id: u128) -> felt252;

    /// Returns the withdrawable amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn withdrawable_amount_of(self: @TContractState, stream_id: u64) -> u128;

    /// Returns the status of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    // fn status_of(self : @TContractState, stream_id : u64) -> Status;

    /// Returns the amount of tokens streamed.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    // fn streamed_amount_of(self : @TContractState, stream_id : u64) -> u128;

    /// Returns if the stream was canceled.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn was_canceled(self: @TContractState, stream_id: u64) -> bool;

    //////////////////////////////////////////////////////////////////////////
    //USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////

    /// Create a new stream with a duration.
    /// # Arguments
    /// * `sender` - The address streaming the assets, with the ability to cancel the stream.
    /// * `recipient` - The address receiving the assets.
    /// * `total_amount` - The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
    /// * `asset` - The contract address of the ERC-20 asset used for streaming.
    /// * `cancelable` - Indicates if the stream is cancelable.
    /// * `transferable` - Indicates if the stream is transferable.
    /// * `duration` - The duration of the stream. Struct containing (i) the stream's cliff period, (ii) total duration
    /// * `broker` - The broker of the stream.  Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`.
    fn create_with_duration(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        total_amount: u128,
        asset: ContractAddress,
        cancelable: bool,
        transferable: bool,
        duration: Durations,
        broker: Broker
    ) -> u64;

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
        transferable: bool,
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
    use core::starknet::event::EventEmitter;
    use core::result::ResultTrait;
    use starknet::{
        get_caller_address, ContractAddress, contract_address_const, get_contract_address,
        get_block_timestamp
    };
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;
    use zeroable::Zeroable;
    // Local imports.
    use tokei::types::lockup_linear::{Range, Broker, LockupLinearStream, Durations};
    use tokei::types::lockup::{Status, LockupAmounts};
    use tokei::tokens::erc721::{ERC721, IERC721};
    use tokei::tokens::erc20::{ERC20, IERC20, IERC20Dispatcher, IERC20DispatcherTrait};

    use tokei::libraries::helpers;
    use tokei::libraries::errors::Lockup::{STREAM_NOT_CANCELABLE, STREAM_SETTLED};

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        admin: ContractAddress,
        next_stream_id: u64,
        streams: LegacyMap<u64, LockupLinearStream>,
    }

    const MAX_FEE: u128 = 100000000000000000;

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
        //////////////////////////////////////////////////////////////////////////
        //USER-FACING CONSTANT FUNCTIONS
        //////////////////////////////////////////////////////////////////////////

        fn get_asset(self: @ContractState, stream_id: u64) -> ContractAddress {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).asset
        }

        /// Returns the cliff time of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_cliff_time(self: @ContractState, stream_id: u64) -> u64 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).start_time
        }

        /// Returns the deposited amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_deposited_amount(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).amounts.deposited
        }

        /// Returns the end time of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_end_time(self: @ContractState, stream_id: u64) -> u64 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).end_time
        }

        /// Returns the Range of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_range(self: @ContractState, stream_id: u64) -> Range {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let stream = self.streams.read(stream_id);
            Range { start: stream.start_time, cliff: stream.start_time, end: stream.end_time, }
        }

        /// Returns the refundable amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_refunded_amount(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).amounts.refunded
        }

        /// Returns the sender address of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_sender(self: @ContractState, stream_id: u64) -> ContractAddress {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).sender
        }

        /// Returns the start time of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_start_time(self: @ContractState, stream_id: u64) -> u64 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).start_time
        }

        /// Returns the stream state of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_stream(ref self: ContractState, stream_id: u64) -> LockupLinearStream {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let stream = self.streams.read(stream_id);

            if (TokeiInternalImpl::_status_of(@self, stream_id) == Status::SETTLED) {
                let stream_updated = LockupLinearStream {
                    sender: stream.sender,
                    asset: stream.asset,
                    start_time: stream.start_time,
                    end_time: stream.end_time,
                    is_cancelable: false,
                    was_canceled: stream.was_canceled,
                    is_depleted: stream.is_depleted,
                    is_stream: stream.is_stream,
                    is_transferable: stream.is_transferable,
                    amounts: LockupAmounts {
                        deposited: stream.amounts.deposited,
                        withdrawn: stream.amounts.withdrawn,
                        refunded: stream.amounts.refunded,
                    },
                };

                self.streams.write(stream_id, stream_updated);

                self.streams.read(stream_id)
            } else {
                self.streams.read(stream_id)
            }
        }

        /// Returns the withdrawn amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_withdrawn_amount(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).amounts.withdrawn
        }

        /// Returns if the stream is cancelable.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn is_cancelable(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).is_cancelable
        }

        /// Returns if the stream is transferable.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn is_transferable(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).is_transferable
        }

        /// Returns if the stream is depleted.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn is_depleted(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).is_depleted
        }

        /// Returns if the stream is canceled.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn is_stream(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).is_stream
        }

        /// Returns the refundable amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn refundable_amount_of(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            if (self.streams.read(stream_id).is_cancelable
                && !self.streams.read(stream_id).is_depleted) {
                self.streams.read(stream_id).amounts.deposited
                    - TokeiInternalImpl::_calculate_streamed_amount(self, stream_id)
            } else {
                0
            }
        }


        fn was_canceled(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).was_canceled
        }

        fn get_recipient(self: @ContractState, stream_id: u64) -> ContractAddress {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            // @todo - Add _ownerof the stream
            self.streams.read(stream_id).asset
        }

        fn is_cold(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let status = TokeiInternalImpl::_status_of(self, stream_id);
            let result = status == Status::CANCELED
                || status == Status::DEPLETED
                || status == Status::SETTLED;
            result
        }

        fn is_warm(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let status = TokeiInternalImpl::_status_of(self, stream_id);
            let result = status == Status::PENDING || status == Status::STREAMING;
            result
        }

        fn token_uri(self: @ContractState, token_id: u128) -> felt252 {
            // TokeiInternalImpl::_token_uri(@self, token_id)
            // @todo - Complete require minted function
            '1'
        }

        fn withdrawable_amount_of(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            // @todo - internal function withdrawal amount of
            // TokeiInternalImpl::_withdrawa(@self, stream_id);
            // let result = status == Status::PENDING || status == Status::STREAMING;
            // result
            1_u128
        }

        fn create_with_range(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            total_amount: u128,
            asset: ContractAddress,
            cancelable: bool,
            transferable: bool,
            range: Range,
            broker: Broker,
        ) -> u64 {
            // Safe Interactions: query the protocol fee. This is safe because it's a known Tokei contract that does
            // not call other unknown contracts.
            // TODO: implement.
            TokeiInternalImpl::_create_with_range(
                ref self,
                sender,
                recipient,
                total_amount,
                asset,
                cancelable,
                transferable,
                range,
                broker,
            )
        }
        fn create_with_duration(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            total_amount: u128,
            asset: ContractAddress,
            cancelable: bool,
            transferable: bool,
            duration: Durations,
            broker: Broker
        ) -> u64 {
            let range = Range {
                start: get_block_timestamp(),
                cliff: get_block_timestamp() + duration.cliff,
                end: get_block_timestamp() + duration.total,
            };

            let stream_id = TokeiInternalImpl::_create_with_range(
                ref self,
                sender,
                recipient,
                total_amount,
                asset,
                cancelable,
                transferable,
                range,
                broker,
            );

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

    ///////////////////////////////////////////////////////////////////////////
    ///INTERNAL CONSTANT FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    #[generate_trait]
    impl TokeiInternalImpl of TokeiInternalTrait {
        fn _calculate_streamed_amount(self: @ContractState, stream_id: u64) -> u128 {
            let cliff_time = self.streams.read(stream_id).end_time;
            let current_time = get_block_timestamp();

            // If the cliff time is in the future, return zero.
            if (current_time < cliff_time) {
                return 0;
            }

            // If the end time is not in the future, return the deposited amount.
            let end_time = self.streams.read(stream_id).end_time;
            if (current_time >= end_time) {
                return self.streams.read(stream_id).amounts.deposited;
            }

            let start_time = self.streams.read(stream_id).start_time;
            let elapsed_time = current_time - start_time;
            let total_time = end_time - start_time;

            // Divide the elapsed time by the stream's total duration.
            let elapsed_time_percentage = elapsed_time / total_time;
            let deposited_amount = self.streams.read(stream_id).amounts.deposited;
            // Convert the percentage to a felt252 and then to a u128.
            let elapsed_time_percentage_felt: felt252 = elapsed_time_percentage.into();
            let elapsed_time_percentage_u128: u128 = elapsed_time_percentage_felt
                .try_into()
                .unwrap();
            // Multiply the deposited amount by the percentage.
            let streamed_amount = deposited_amount * elapsed_time_percentage_u128;

            // Although the streamed amount should never exceed the deposited amount, this condition is checked
            // without asserting to avoid locking funds in case of a bug. If this situation occurs, the withdrawn
            // amount is considered to be the streamed amount, and the stream is effectively frozen.
            if (streamed_amount > deposited_amount) {
                return self.streams.read(stream_id).amounts.withdrawn;
            }

            return streamed_amount;
        }

        fn _status_of(self: @ContractState, stream_id: u64) -> Status {
            if (self.streams.read(stream_id).is_depleted) {
                return Status::DEPLETED;
            } else if (self.streams.read(stream_id).was_canceled) {
                return Status::CANCELED;
            }

            if (get_block_timestamp() < self.streams.read(stream_id).start_time) {
                return Status::PENDING;
            }

            if (TokeiInternalImpl::_calculate_streamed_amount(self, stream_id) < self
                .streams
                .read(stream_id)
                .amounts
                .deposited) {
                return Status::STREAMING;
            } else {
                return Status::SETTLED;
            }
        }

        fn _withdraw(ref self: ContractState, stream_id: u64, to: ContractAddress, amount: u128) {
            let stream = self.streams.read(stream_id);
            let stream_updated = LockupLinearStream {
                sender: stream.sender,
                asset: stream.asset,
                start_time: stream.start_time,
                end_time: stream.end_time,
                is_cancelable: stream.is_cancelable,
                was_canceled: stream.was_canceled,
                is_depleted: stream.is_depleted,
                is_stream: stream.is_stream,
                is_transferable: stream.is_transferable,
                amounts: LockupAmounts {
                    deposited: stream.amounts.deposited,
                    withdrawn: stream.amounts.withdrawn + amount,
                    refunded: stream.amounts.refunded,
                },
            };
            self.streams.write(stream_id, stream_updated);

            let amounts = stream.amounts;

            if (amounts.withdrawn >= amounts.deposited - amounts.refunded) {
                let _stream_updated = LockupLinearStream {
                    sender: stream.sender,
                    asset: stream.asset,
                    start_time: stream.start_time,
                    end_time: stream.end_time,
                    is_cancelable: false,
                    was_canceled: stream.was_canceled,
                    is_depleted: true,
                    is_stream: stream.is_stream,
                    is_transferable: stream.is_transferable,
                    amounts: LockupAmounts {
                        deposited: stream.amounts.deposited,
                        withdrawn: stream.amounts.withdrawn,
                        refunded: stream.amounts.refunded,
                    },
                };
                self.streams.write(stream_id, _stream_updated);
            }

            let asset = stream.asset;
            IERC20Dispatcher { contract_address: asset }.transfer(to, amount.into());
        // self.emit( Withdrawn {
        //     stream_id,
        //     to,
        //     amount,
        // });
        //@todo - Emit the Withdrawn event.
        }

        fn _renounce(ref self: ContractState, stream_id: u64) {
            let stream = self.streams.read(stream_id);
            // Checks: the stream is cancelable.
            assert(!stream.is_cancelable, STREAM_NOT_CANCELABLE);
            let stream_updated = LockupLinearStream {
                sender: stream.sender,
                asset: stream.asset,
                start_time: stream.start_time,
                end_time: stream.end_time,
                is_cancelable: stream.is_cancelable,
                was_canceled: stream.was_canceled,
                is_depleted: stream.is_depleted,
                is_stream: false,
                is_transferable: stream.is_transferable,
                amounts: LockupAmounts {
                    deposited: stream.amounts.deposited,
                    withdrawn: stream.amounts.withdrawn,
                    refunded: stream.amounts.refunded,
                },
            };
            // renounce the stream by making it not cancelable.
            self.streams.write(stream_id, stream_updated);
        }

        fn _cancel(ref self: ContractState, stream_id: u64) {
            let streamed_amount = TokeiInternalImpl::_calculate_streamed_amount(@self, stream_id);

            let amounts = self.streams.read(stream_id).amounts;

            assert(streamed_amount >= amounts.deposited, STREAM_SETTLED);

            assert(!self.streams.read(stream_id).is_cancelable, STREAM_NOT_CANCELABLE);

            let sender_amount = amounts.deposited - streamed_amount;
            let recipient_amount = streamed_amount - amounts.withdrawn;

            if (recipient_amount == 0) {
                let stream = self.streams.read(stream_id);
                let stream_updated = LockupLinearStream {
                    sender: stream.sender,
                    asset: stream.asset,
                    start_time: stream.start_time,
                    end_time: stream.end_time,
                    is_cancelable: false,
                    was_canceled: true,
                    is_depleted: true,
                    is_stream: stream.is_stream,
                    is_transferable: stream.is_transferable,
                    amounts: LockupAmounts {
                        deposited: stream.amounts.deposited,
                        withdrawn: stream.amounts.withdrawn,
                        refunded: stream.amounts.refunded,
                    },
                };

                self.streams.write(stream_id, stream_updated);
            }
            let stream = self.streams.read(stream_id);

            let stream_updated = LockupLinearStream {
                sender: stream.sender,
                asset: stream.asset,
                start_time: stream.start_time,
                end_time: stream.end_time,
                is_cancelable: false,
                was_canceled: true,
                is_depleted: stream.is_depleted,
                is_stream: stream.is_stream,
                is_transferable: stream.is_transferable,
                amounts: LockupAmounts {
                    deposited: stream.amounts.deposited,
                    withdrawn: stream.amounts.withdrawn,
                    refunded: sender_amount,
                },
            };

            self.streams.write(stream_id, stream_updated);

            let sender = stream.sender;
            let recipient = stream
                .asset; // @todo -  This is incorrect it should be _ownerof(stream_id)

            IERC20Dispatcher { contract_address: stream.asset }
                .transfer(sender, sender_amount.into());
        // @todo - Emit the Canceled event.
        // @todo - Emit Metadataupdated event.

        }

        fn _withdrawable_amount_of(self: @ContractState, stream_id: u64) -> u128 {
            TokeiInternalImpl::_calculate_streamed_amount(self, stream_id)
                - self.streams.read(stream_id).amounts.withdrawn
        }

        fn _streamed_amount_of(self: @ContractState, stream_id: u64) -> u128 {
            let stream = self.streams.read(stream_id);
            let amounts = stream.amounts;

            if (stream.is_depleted) {
                return amounts.withdrawn;
            } else if (stream.was_canceled) {
                return amounts.deposited - amounts.refunded;
            }

            TokeiInternalImpl::_calculate_streamed_amount(self, stream_id)
        }

        fn _is_caller_stream_sender(self: @ContractState, stream_id: u64) -> bool {
            let stream = self.streams.read(stream_id);
            get_caller_address() == stream.sender
        }

        fn _create_with_range(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            total_amount: u128,
            asset: ContractAddress,
            cancelable: bool,
            transferable: bool,
            range: Range,
            broker: Broker,
        ) -> u64 {
            // Safe Interactions: query the protocol fee. This is safe because it's a known Tokei contract that does
            // not call other unknown contracts.
            // TODO: implement.

            let caller = get_caller_address();
            let this = get_contract_address();

            // Checks: validate the user-provided parameters.
            // Sanity checks

            assert(sender != Zeroable::zero(), 'Invalid Sender Address');
            assert(recipient != Zeroable::zero(), 'Invalid Recipient Address');
            assert(broker.account != Zeroable::zero(), 'Invalid broker Address');
            assert(asset != Zeroable::zero(), 'Invalid asset Address');
            assert(total_amount != Zeroable::zero(), 'Invalid total Amount');

            // TODO: Handle MAX_FEE as a constant, with handlign of fixed point numbers.
            // let MAX_FEE = 100000000000000000;

            // Read the next stream id from storage.
            let stream_id = self.next_stream_id.read();

            // Checks: check the fees and calculate the fee amounts.
            let deposited_amount = total_amount - broker.fee;

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
                is_stream: true,
                is_transferable: transferable,
                amounts,
            };
            self.streams.write(stream_id, stream);

            // Effects: bump the next stream id.
            self.next_stream_id.write(stream_id + 1);

            // Effects: mint the NFT to the recipient.
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::mint(ref state, recipient, stream_id.into());

            // Interactions: transfer the deposit and the protocol fee.
            // Casting u128 to u256 for the transfer from function
            let deposit_u256: u256 = amounts.deposited.into();

            IERC20Dispatcher { contract_address: asset }.transfer_from(caller, this, deposit_u256);

            // Interactions: pay the broker fee, if not zero.
            if (broker.fee > 0) {
                let broker_fee_u256: u256 = broker.fee.into();
                IERC20Dispatcher { contract_address: asset }
                    .transfer_from(caller, broker.account, broker_fee_u256);
            }

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

        fn _is_caller_stream_recipient_or_approved(self: @ContractState, stream_id: u64) -> bool {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            let stream_id_u128: u128 = stream_id.into();
            let recipient = IERC721::owner_of(@state, stream_id_u128);
            return get_caller_address() == recipient
                || IERC721::get_approved(@state, stream_id_u128) == get_caller_address()
                || IERC721::is_approved_for_all(@state, recipient, get_caller_address());
        }
    // @todo - Implement Internal functions (_afterTokenTransfer,_beforeTokenTransfer,,_cancel ,,,)
    // Implemented Internal functions (_isCallerStreamRecipientOrApproved,_is_caller_stream_sender,_streamed_amount_of,_withdrawable_amount_of,_status_of,_calculate_streamed_amount,_withdraw,_renounce)
    }
}
