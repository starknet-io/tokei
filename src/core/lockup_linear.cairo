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
    fn status_of(self: @TContractState, stream_id: u64) -> Status;

    /// Returns the amount of tokens streamed.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn streamed_amount_of(self: @TContractState, stream_id: u64) -> u128;

    /// Returns if the stream was canceled.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn was_canceled(self: @TContractState, stream_id: u64) -> bool;

    /// Returns the amount of protocol revenues for the given asset.
    /// # Arguments
    /// * `asset` - The asset to claim the protocol revenues for.
    fn get_protocol_revenues(self: @TContractState, asset: ContractAddress) -> u128;

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

    /// Burns the NFT token of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn burn_token(ref self: TContractState, stream_id: u64);

    // /// Cancels the stream.
    // /// # Arguments
    // /// * `stream_id` - The id of the stream.
    fn cancel(ref self: TContractState, stream_id: u64);

    // /// Cancels multiple streams.
    // /// # Arguments
    // /// * `stream_ids` - The ids of the streams.
    fn cancel_multiple(ref self: TContractState, stream_ids: Span<u64>);
    /// Renounces the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn renounce(ref self: TContractState, stream_id: u64);

    /// Sets the NFT descriptor.
    /// # Arguments
    /// * `nft_descriptor` - The NFT descriptor.
    fn set_nft_descriptor(ref self: TContractState, nft_descriptor: ContractAddress);

    /// Withdraws the stream's assets.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    /// * `to` - The address to withdraw the assets to.
    /// * `amount` - The amount of assets to withdraw.
    fn withdraw(ref self: TContractState, stream_id: u64, to: ContractAddress, amount: u128);

    /// Withdraws the maximum amount of the stream's assets.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    /// * `to` - The address to withdraw the assets to.
    fn withdraw_max(ref self: TContractState, stream_id: u64, to: ContractAddress);

    /// Withdraws the stream's assets and transfers the NFT token.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    /// * `new_recipient` - The address to withdraw the assets to.
    fn withdraw_max_and_transfer(
        ref self: TContractState, stream_id: u64, new_recipient: ContractAddress
    );

    /// Withdraws multiple streams' assets.
    /// # Arguments
    /// * `stream_ids` - The ids of the streams.
    /// * `to` - The address to withdraw the assets to.
    /// * `amounts` - The amounts of assets to withdraw.
    fn withdraw_multiple(
        ref self: TContractState, stream_ids: Span<u64>, to: ContractAddress, amounts: Span<u128>
    );

    //Comptroller functions
    /// Sets the flash fee.
    /// # Arguments
    /// * `new_flash_fee` - The new flash fee.
    fn set_flash_fee(ref self: TContractState, new_flash_fee: u128);

    /// Sets the protocol fee.
    /// # Arguments
    /// * `asset` - The asset to set the protocol fee for.
    /// * `new_protocol_fee` - The new protocol fee.
    fn set_protocol_fee(ref self: TContractState, asset: ContractAddress, new_protocol_fee: u128);

    /// Toggle flash assets.
    /// # Arguments
    /// * `asset` - The asset to toggle.
    fn toggle_flash_assets(ref self: TContractState, asset: ContractAddress);

    /// Transfers the admin.
    /// # Arguments
    /// * `new_admin` - The new admin.
    fn transfer_admin(ref self: TContractState, new_admin: ContractAddress);

    /// Claims the protocol revenues.
    /// # Arguments
    /// * `asset` - The asset to claim the protocol revenues for.
    fn claim_protocol_revenues(ref self: TContractState, asset: ContractAddress);
}

#[starknet::contract]
mod TokeiLockupLinear {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************

    // Core lib imports.
    use tokei::core::lockup_linear::ITokeiLockupLinear;
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
    use tokei::tokens::erc721::{ERC721, IERC721, IERC721Metadata};
    use tokei::tokens::erc20::{ERC20, IERC20, IERC20Dispatcher, IERC20DispatcherTrait};

    use tokei::libraries::helpers::{check_and_calculate_fees, check_create_with_range};
    use tokei::libraries::errors::Lockup::{
        STREAM_NOT_CANCELABLE, STREAM_SETTLED, STREAM_NOT_DEPLETED, LOCKUP_UNAUTHORIZED,
        STREAM_DEPLETED, STREAM_CANCELED, INVALID_SENDER_WITHDRAWAL, WITHDRAW_TO_ZERO_ADDRESS,
        WITHDRAW_ZERO_AMOUNT, OVERDRAW, NO_PROTOCOL_REVENUE
    };

    // @todo - Implement erc721 with openzeppelin component
    // use openzeppelin::token::erc721::erc721::ERC721Component;
    // use openzeppelin::token::erc721::erc721::ERC721Component::InternalTrait;
    // use openzeppelin::introspection::src5::SRC5Component;

    // *************************************************************************
    //                              COMPONENTS
    // *************************************************************************
    // component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    // component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // #[abi(embed_v0)]
    // impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    // #[abi(embed_v0)]
    // impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;
    // impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        admin: ContractAddress,
        next_stream_id: u64,
        streams: LegacyMap<u64, LockupLinearStream>,
        nft_descriptor: ContractAddress,
        //Comptroller
        flash_fee: u128,
        is_flash_asset: LegacyMap<ContractAddress, bool>,
        protocol_fee: LegacyMap<ContractAddress, u128>,
        //Base
        protocol_revenues: LegacyMap<ContractAddress, u128>,
    //Component
    // #[substorage(v0)]
    // src5: SRC5Component::Storage,
    // #[substorage(v0)]
    // erc721: ERC721Component::Storage,
    }

    const MAX_FEE: u128 = 100000000000000000;

    // *************************************************************************
    // EVENTS
    // *************************************************************************

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        LockupLinearStreamCreated: LockupLinearStreamCreated,
        RenounceLockupStream: RenounceLockupStream,
        SetNFTDescriptor: SetNFTDescriptor,
        TransferAdmin: TransferAdmin,
        SetFlashFee: SetFlashFee,
        SetProtocolFee: SetProtocolFee,
        ToggleFlashAsset: ToggleFlashAsset,
        CancelLockupStream: CancelLockupStream,
        WithdrawFromLockupStream: WithdrawFromLockupStream,
        ClaimProtocolRevenues: ClaimProtocolRevenues,
    //Component
    // #[flat]
    // SRC5Event: SRC5Component::Event,
    // #[flat]
    // ERC721Event: ERC721Component::Event,
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

    #[derive(Drop, starknet::Event)]
    struct RenounceLockupStream {
        stream_id: u64
    }

    #[derive(Drop, starknet::Event)]
    struct SetNFTDescriptor {
        admin: ContractAddress,
        old_nft_descriptor: ContractAddress,
        new_nft_descriptor: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct TransferAdmin {
        old_admin: ContractAddress,
        new_admin: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct SetFlashFee {
        admin: ContractAddress,
        old_flash_fee: u128,
        new_flash_fee: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct SetProtocolFee {
        admin: ContractAddress,
        asset: ContractAddress,
        old_protocol_fee: u128,
        new_protocol_fee: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct ToggleFlashAsset {
        admin: ContractAddress,
        asset: ContractAddress,
        new_flag: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct CancelLockupStream {
        stream_id: u64,
        sender: ContractAddress,
        recipient: ContractAddress,
        asset: ContractAddress,
        sender_amount: u128,
        recipient_amount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct WithdrawFromLockupStream {
        stream_id: u64,
        to: ContractAddress,
        asset: ContractAddress,
        amount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct ClaimProtocolRevenues {
        admin: ContractAddress,
        asset: ContractAddress,
        amount: u128,
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
        // self.erc721.initializer('Tokei Lockup Linear NFT', 'ZW-LOCKUP-LIN');

        self.emit(TransferAdmin { old_admin: Zeroable::zero(), new_admin: initial_admin, });
    // @todo - nft_descriptor write
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
            self.streams.read(stream_id).cliff_time
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
            Range { start: stream.start_time, cliff: stream.cliff_time, end: stream.end_time, }
        }

        /// Returns the refundable amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_refunded_amount(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).amounts.refunded
        }

        fn status_of(self: @ContractState, stream_id: u64) -> Status {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            TokeiInternalImpl::_status_of(self, stream_id)
        }

        fn streamed_amount_of(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            TokeiInternalImpl::_streamed_amount_of(self, stream_id)
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

        /// Returns the stream state for the given stream id.
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
                    cliff_time: stream.cliff_time,
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
                stream
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
        // @todo - Fn check - Should it be `wasCanceled` or is it supposed to be !is_depleted check
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
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::owner_of(@state, stream_id.into())
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
            assert(Zeroable::is_non_zero(token_id), 'Invalid stream id');
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721Metadata::token_uri(@state, token_id)
        //@todo from the nftdescriptor
        }

        fn withdrawable_amount_of(self: @ContractState, stream_id: u64) -> u128 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self._withdrawable_amount_of(stream_id)
        }

        fn get_protocol_revenues(self: @ContractState, asset: ContractAddress) -> u128 {
            assert(Zeroable::is_non_zero(asset), 'Invalid asset');
            self.protocol_revenues.read(asset)
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
            let start_time = get_block_timestamp();
            let range = Range {
                start: start_time,
                cliff: start_time + duration.cliff,
                end: start_time + duration.total,
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
        fn burn_token(ref self: ContractState, stream_id: u64) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(self.is_depleted(stream_id), STREAM_NOT_DEPLETED);
            assert(
                TokeiInternalImpl::_is_caller_stream_recipient_or_approved(@self, stream_id),
                LOCKUP_UNAUTHORIZED
            );

            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::burn(ref self, stream_id.into());
        }

        fn cancel(ref self: ContractState, stream_id: u64) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(!self.is_depleted(stream_id), STREAM_DEPLETED);
            assert(!self.was_canceled(stream_id), STREAM_CANCELED);
            assert(
                self._is_caller_stream_sender(stream_id)
                    && get_caller_address() != self.get_recipient(stream_id),
                LOCKUP_UNAUTHORIZED
            );

            TokeiInternalImpl::_cancel(ref self, stream_id);
        }


        fn cancel_multiple(ref self: ContractState, stream_ids: Span<u64>) {
            let count = stream_ids.len();
            let mut i = 0;
            loop {
                if i >= count {
                    break;
                }
                let stream_id = *stream_ids.at(i);
                self.cancel(stream_id);
                i += 1;
            };
        }

        fn renounce(ref self: ContractState, stream_id: u64) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let status = self._status_of(stream_id);
            assert(status != Status::DEPLETED, STREAM_DEPLETED);
            assert(status != Status::CANCELED, STREAM_CANCELED);
            assert(status != Status::SETTLED, STREAM_SETTLED);
            assert(self._is_caller_stream_sender(stream_id), LOCKUP_UNAUTHORIZED);

            self._renounce(stream_id);
        }

        fn set_nft_descriptor(ref self: ContractState, nft_descriptor: ContractAddress) {
            assert(Zeroable::is_non_zero(nft_descriptor), 'Invalid nft descriptor');
            assert(get_caller_address() == self.admin.read(), LOCKUP_UNAUTHORIZED);
            let old_nft_descriptor = self.nft_descriptor.read();
            self.nft_descriptor.write(nft_descriptor);

            self
                .emit(
                    SetNFTDescriptor {
                        admin: self.admin.read(),
                        old_nft_descriptor: old_nft_descriptor,
                        new_nft_descriptor: nft_descriptor,
                    }
                );
        }

        fn withdraw(ref self: ContractState, stream_id: u64, to: ContractAddress, amount: u128) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(Zeroable::is_non_zero(amount), WITHDRAW_ZERO_AMOUNT);
            assert(to != Zeroable::zero(), WITHDRAW_TO_ZERO_ADDRESS);
            assert(!self.is_depleted(stream_id), STREAM_DEPLETED);
            assert(
                TokeiInternalImpl::_is_caller_stream_sender(@self, stream_id)
                    && TokeiInternalImpl::_is_caller_stream_recipient_or_approved(@self, stream_id),
                LOCKUP_UNAUTHORIZED
            );

            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            let recipient = IERC721::owner_of(@state, stream_id.into());

            assert(
                !TokeiInternalImpl::_is_caller_stream_sender(@self, stream_id) && to == recipient,
                INVALID_SENDER_WITHDRAWAL
            );

            TokeiInternalImpl::_withdraw(ref self, stream_id, to, amount);
        // @todo - OnstreamWithdrawn
        }


        fn withdraw_max(ref self: ContractState, stream_id: u64, to: ContractAddress) {
            self.withdraw(stream_id, to, self.withdrawable_amount_of(stream_id));
        }

        fn withdraw_max_and_transfer(
            ref self: ContractState, stream_id: u64, new_recipient: ContractAddress
        ) {
            let current_recipient = self.get_recipient(stream_id);
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(Zeroable::is_non_zero(new_recipient), 'Invalid new_recipient');
            assert(get_caller_address() == current_recipient, LOCKUP_UNAUTHORIZED);
            let withdrawable_amount = self.withdrawable_amount_of(stream_id);
            if (withdrawable_amount > 0) {
                // @todo change this from_withdraw to withdraw
                self._withdraw(stream_id, current_recipient, withdrawable_amount);
            }

            let stream_id_u128: u128 = stream_id.into();

            self.transfer_from(current_recipient, new_recipient, stream_id_u128);
        }

        fn withdraw_multiple(
            ref self: ContractState, stream_ids: Span<u64>, to: ContractAddress, amounts: Span<u128>
        ) {
            let stream_ids_count = stream_ids.len();
            let amounts_count = amounts.len();
            assert(stream_ids_count == amounts_count, 'Invalid array lengths');
            let mut i = 0;
            loop {
                if i >= stream_ids_count {
                    break;
                }
                let stream_id = *stream_ids.at(i);
                let amount = *amounts.at(i);
                self.withdraw(stream_id, to, amount);
                i += 1;
            };
        }

        fn set_flash_fee(ref self: ContractState, new_flash_fee: u128) {
            assert(get_caller_address() == self.admin.read(), LOCKUP_UNAUTHORIZED);
            let old_fee = self.flash_fee.read();
            self.flash_fee.write(new_flash_fee);

            self
                .emit(
                    SetFlashFee {
                        admin: self.admin.read(),
                        old_flash_fee: old_fee,
                        new_flash_fee: new_flash_fee,
                    }
                );
        }


        fn set_protocol_fee(
            ref self: ContractState, asset: ContractAddress, new_protocol_fee: u128
        ) {
            assert(get_caller_address() == self.admin.read(), LOCKUP_UNAUTHORIZED);
            let old_protocol_fee = self.protocol_fee.read(asset);
            self.protocol_fee.write(asset, new_protocol_fee);

            self
                .emit(
                    SetProtocolFee {
                        admin: self.admin.read(),
                        asset: asset,
                        old_protocol_fee: old_protocol_fee,
                        new_protocol_fee: new_protocol_fee,
                    }
                );
        }


        fn toggle_flash_assets(ref self: ContractState, asset: ContractAddress) {
            assert(get_caller_address() == self.admin.read(), LOCKUP_UNAUTHORIZED);
            let old_flag = self.is_flash_asset.read(asset);
            self.is_flash_asset.write(asset, !old_flag);

            self
                .emit(
                    ToggleFlashAsset {
                        admin: self.admin.read(), asset: asset, new_flag: !old_flag,
                    }
                );
        }

        fn transfer_admin(ref self: ContractState, new_admin: ContractAddress) {
            assert(get_caller_address() == self.admin.read(), LOCKUP_UNAUTHORIZED);
            let old_admin = self.admin.read();
            self.admin.write(new_admin);

            self.emit(TransferAdmin { old_admin: old_admin, new_admin: new_admin, });
        }

        fn claim_protocol_revenues(ref self: ContractState, asset: ContractAddress) {
            assert(get_caller_address() == self.admin.read(), LOCKUP_UNAUTHORIZED);
            let protocol_revenues = self.protocol_revenues.read(asset);
            assert(protocol_revenues > 0, NO_PROTOCOL_REVENUE);

            self.protocol_revenues.write(asset, 0);

            IERC20Dispatcher { contract_address: asset }
                .transfer(self.admin.read(), protocol_revenues.into());

            self
                .emit(
                    ClaimProtocolRevenues {
                        admin: self.admin.read(), asset: asset, amount: protocol_revenues
                    }
                );
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
        fn burn(ref self: ContractState, token_id: u128) {
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            IERC721::burn(ref state, token_id)
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
            let withdrawable_amount = self._withdrawable_amount_of(stream_id);
            assert(amount < withdrawable_amount, OVERDRAW);
            let stream = self.streams.read(stream_id);
            let stream_updated = LockupLinearStream {
                sender: stream.sender,
                asset: stream.asset,
                start_time: stream.start_time,
                cliff_time: stream.cliff_time,
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
                    cliff_time: stream.cliff_time,
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
            self.emit(WithdrawFromLockupStream { stream_id, to, asset, amount, });
        // @todo - OnstreamWithdrawn
        }

        fn _renounce(ref self: ContractState, stream_id: u64) {
            let stream = self.streams.read(stream_id);
            // Checks: the stream is cancelable.
            assert(stream.is_cancelable, STREAM_NOT_CANCELABLE);
            let stream_updated = LockupLinearStream {
                sender: stream.sender,
                asset: stream.asset,
                start_time: stream.start_time,
                cliff_time: stream.cliff_time,
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
            // renounce the stream by making it not cancelable.
            self.streams.write(stream_id, stream_updated);

            self.emit(RenounceLockupStream { stream_id });
            let mut state: ERC721::ContractState = ERC721::unsafe_new_contract_state();
            let recipient = IERC721::owner_of(@state, stream_id.into());
        // @todo - Lockuprecipient onstreamRenounced

        }

        fn _cancel(ref self: ContractState, stream_id: u64) {
            let streamed_amount = TokeiInternalImpl::_calculate_streamed_amount(@self, stream_id);

            let amounts = self.streams.read(stream_id).amounts;

            assert(streamed_amount < amounts.deposited, STREAM_SETTLED);

            assert(self.streams.read(stream_id).is_cancelable, STREAM_NOT_CANCELABLE);

            let sender_amount = amounts.deposited - streamed_amount;
            let recipient_amount = streamed_amount - amounts.withdrawn;

            if (recipient_amount == 0) {
                let stream = self.streams.read(stream_id);
                let stream_updated = LockupLinearStream {
                    sender: stream.sender,
                    asset: stream.asset,
                    start_time: stream.start_time,
                    cliff_time: stream.cliff_time,
                    end_time: stream.end_time,
                    is_cancelable: false,
                    was_canceled: true,
                    is_depleted: true,
                    is_stream: stream.is_stream,
                    is_transferable: stream.is_transferable,
                    amounts: LockupAmounts {
                        deposited: stream.amounts.deposited,
                        withdrawn: stream.amounts.withdrawn,
                        refunded: sender_amount,
                    },
                };

                self.streams.write(stream_id, stream_updated);
            }
            let stream = self.streams.read(stream_id);

            let stream_updated = LockupLinearStream {
                sender: stream.sender,
                asset: stream.asset,
                start_time: stream.start_time,
                cliff_time: stream.cliff_time,
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
            let recipient = self.get_recipient(stream_id);

            IERC20Dispatcher { contract_address: stream.asset }
                .transfer(sender, sender_amount.into());
            self
                .emit(
                    CancelLockupStream {
                        stream_id,
                        sender,
                        recipient,
                        asset: stream.asset,
                        sender_amount,
                        recipient_amount,
                    }
                );
        // @todo onstreamCanceled
        // @todo - Emit Metadataupdated event.

        }

        fn _withdrawable_amount_of(self: @ContractState, stream_id: u64) -> u128 {
            TokeiInternalImpl::_streamed_amount_of(self, stream_id)
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
            let protocol_fee = self.protocol_fee.read(asset);
            let create_amounts = check_and_calculate_fees(
                total_amount, protocol_fee, broker.fee, MAX_FEE
            );

            check_create_with_range(create_amounts.deposit, range);

            let caller = get_caller_address();
            let this = get_contract_address();

            // Checks: validate the user-provided parameters.
            // Sanity checks

            assert(sender != Zeroable::zero(), 'Invalid Sender Address');
            assert(recipient != Zeroable::zero(), 'Invalid Recipient Address');
            assert(broker.account != Zeroable::zero(), 'Invalid broker Address');
            assert(asset != Zeroable::zero(), 'Invalid asset Address');
            assert(total_amount != Zeroable::zero(), 'Invalid total Amount');

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
                cliff_time: range.cliff,
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

            let protocol_revenue = self.protocol_revenues.read(asset) + create_amounts.protocol_fee;
            self.protocol_revenues.write(asset, protocol_revenue);

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
            let recipient = self.get_recipient(stream_id);

            return get_caller_address() == recipient
                || IERC721::get_approved(@state, stream_id_u128) == get_caller_address()
                || IERC721::is_approved_for_all(@state, recipient, get_caller_address());
        }
    // @todo - Implement Internal functions (_afterTokenTransfer,_beforeTokenTransfer)
    // Implemented Internal functions (_isCallerStreamRecipientOrApproved,_is_caller_stream_sender,_streamed_amount_of,_withdrawable_amount_of,_status_of,_calculate_streamed_amount,_withdraw,_renounce)
    }
}
