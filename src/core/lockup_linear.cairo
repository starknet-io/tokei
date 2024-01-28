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

    /// Returns the next stream id.
    /// # Arguments
    fn get_next_stream_id(self: @TContractState) -> u64;

    /// Returns the cliff time of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_cliff_time(self: @TContractState, stream_id: u64) -> u64;

    /// Returns the deposited amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_deposited_amount(self: @TContractState, stream_id: u64) -> u256;

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
    fn get_refunded_amount(self: @TContractState, stream_id: u64) -> u256;

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
    fn get_stream(self: @TContractState, stream_id: u64) -> LockupLinearStream;

    /// Returns the withdrawn amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn get_withdrawn_amount(self: @TContractState, stream_id: u64) -> u256;

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
    fn refundable_amount_of(self: @TContractState, stream_id: u64) -> u256;

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

    /// Returns the withdrawable amount of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn withdrawable_amount_of(self: @TContractState, stream_id: u64) -> u256;

    /// Returns the status of the stream.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn status_of(self: @TContractState, stream_id: u64) -> Status;

    /// Returns the amount of tokens streamed.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn streamed_amount_of(self: @TContractState, stream_id: u64) -> u256;

    /// Returns if the stream was canceled.
    /// # Arguments
    /// * `stream_id` - The id of the stream.
    fn was_canceled(self: @TContractState, stream_id: u64) -> bool;

    /// Returns the amount of protocol revenues for the given asset.
    /// # Arguments
    /// * `asset` - The asset to claim the protocol revenues for.
    fn get_protocol_revenues(self: @TContractState, asset: ContractAddress) -> u256;

    /// Returns the protocol fee for the given asset.
    /// # Arguments
    /// * `asset` - The asset that has a set protocol fee.
    fn get_protocol_fee(self: @TContractState, asset: ContractAddress) -> u256;

    /// Returns the NFT descriptor address.
    fn get_nft_descriptor(self: @TContractState) -> ContractAddress;

    /// Returns the flash fee
    fn get_flash_fee(self: @TContractState) -> u256;

    /// Returns the admin address.    
    fn get_admin(self: @TContractState) -> ContractAddress;

    /// Returns the streams of the sender.
    /// # Arguments
    /// * `sender` - The address of the sender.
    /// # Returns
    /// * `streams` - The streams of the sender.
    fn get_streams_by_sender(
        self: @TContractState, sender: ContractAddress
    ) -> Array<LockupLinearStream>;

    /// Returns the streams of the recipient.
    /// # Arguments
    /// * `recipient` - The address of the recipient.
    /// # Returns
    /// * `streams` - The streams of the recipient.
    fn get_streams_by_recipient(
        self: @TContractState, recipient: ContractAddress
    ) -> Array<LockupLinearStream>;

    /// Returns the streams ids of the sender.
    /// # Arguments
    /// * `sender` - The address of the sender.
    /// # Returns
    /// * `stream_ids` - The stream ids of the sender.
    fn get_streams_ids_by_sender(self: @TContractState, sender: ContractAddress) -> Array<u64>;

    /// Returns the streams ids of the recipient.
    /// # Arguments
    /// * `recipient` - The address of the recipient.
    /// # Returns
    /// * `stream_ids` - The stream ids of the recipient.
    fn get_streams_ids_by_recipient(
        self: @TContractState, recipient: ContractAddress
    ) -> Array<u64>;


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
        total_amount: u256,
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
        total_amount: u256,
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
    fn withdraw(ref self: TContractState, stream_id: u64, to: ContractAddress, amount: u256);

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
        ref self: TContractState, stream_ids: Span<u64>, to: ContractAddress, amounts: Span<u256>
    );

    //Comptroller functions
    /// Sets the flash fee.
    /// # Arguments
    /// * `new_flash_fee` - The new flash fee.
    fn set_flash_fee(ref self: TContractState, new_flash_fee: u256);

    /// Sets the protocol fee.
    /// # Arguments
    /// * `asset` - The asset to set the protocol fee for.
    /// * `new_protocol_fee` - The new protocol fee.
    fn set_protocol_fee(ref self: TContractState, asset: ContractAddress, new_protocol_fee: u256);

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
    use tokei::core::interface::{ITokeiLockupLinearERC721Snake, ITokeiLockupLinearERC721Camel};
    use tokei::libraries::helpers::{
        scaled_down_div, check_and_calculate_fees, check_create_with_range
    };
    use tokei::libraries::errors::Lockup::{
        STREAM_NOT_CANCELABLE, STREAM_SETTLED, STREAM_NOT_DEPLETED, LOCKUP_UNAUTHORIZED,
        STREAM_DEPLETED, STREAM_CANCELED, INVALID_SENDER_WITHDRAWAL, WITHDRAW_TO_ZERO_ADDRESS,
        WITHDRAW_ZERO_AMOUNT, OVERDRAW, NO_PROTOCOL_REVENUE
    };

    // External Imports
    use openzeppelin::token::erc20::interface::{
        IERC20, IERC20Metadata, ERC20ABIDispatcher, ERC20ABIDispatcherTrait
    };
    use openzeppelin::token::erc721::erc721::ERC721Component;
    use openzeppelin::token::erc721::erc721::ERC721Component::InternalTrait;
    use openzeppelin::introspection::src5::SRC5Component;

    // *************************************************************************
    //                              COMPONENTS
    // *************************************************************************
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;


    #[abi(embed_v0)]
    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        admin: ContractAddress,
        next_stream_id: u64,
        streams: LegacyMap<u64, LockupLinearStream>,
        nft_descriptor: ContractAddress,
        flash_fee: u256,
        is_flash_asset: LegacyMap<ContractAddress, bool>,
        protocol_fee: LegacyMap<ContractAddress, u256>,
        protocol_revenues: LegacyMap<ContractAddress, u256>,
        //Component
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
    }

    // The maximum fee that can be set for the protocol.
    const MAX_FEE: u256 = 10; //0.1%

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
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
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
        old_flash_fee: u256,
        new_flash_fee: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct SetProtocolFee {
        admin: ContractAddress,
        asset: ContractAddress,
        old_protocol_fee: u256,
        new_protocol_fee: u256,
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
        sender_amount: u256,
        recipient_amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct WithdrawFromLockupStream {
        stream_id: u64,
        to: ContractAddress,
        asset: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct ClaimProtocolRevenues {
        admin: ContractAddress,
        asset: ContractAddress,
        amount: u256,
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
        self.erc721.initializer('Tokei Lockup Linear NFT', 'ZW-LOCKUP-LIN');
        // Emit the transfer admin event.
        self.emit(TransferAdmin { old_admin: Zeroable::zero(), new_admin: initial_admin, });
    }

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl TokeiLockupLinear of super::ITokeiLockupLinear<ContractState> {
        //////////////////////////////////////////////////////////////////////////
        //USER-FACING CONSTANT FUNCTIONS
        //////////////////////////////////////////////////////////////////////////

        /// Returns the asset address of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `asset` - The asset address of the stream.
        fn get_asset(self: @ContractState, stream_id: u64) -> ContractAddress {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).asset
        }

        /// Returns the next stream id.
        /// # Arguments
        /// - 
        /// # Returns
        /// * `next_stream_id` - The next stream id.
        fn get_next_stream_id(self: @ContractState) -> u64 {
            self.next_stream_id.read()
        }

        /// Returns the cliff time of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `cliff_time` - The cliff time of the stream.
        fn get_cliff_time(self: @ContractState, stream_id: u64) -> u64 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).cliff_time
        }

        /// Returns the deposited amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `deposited_amount` - The deposited amount of the stream.
        fn get_deposited_amount(self: @ContractState, stream_id: u64) -> u256 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).amounts.deposited
        }

        /// Returns the end time of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `end_time` - The end time of the stream.
        fn get_end_time(self: @ContractState, stream_id: u64) -> u64 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).end_time
        }

        /// Returns the Range of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `range` - The range of the stream.
        fn get_range(self: @ContractState, stream_id: u64) -> Range {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let stream = self.streams.read(stream_id);
            Range { start: stream.start_time, cliff: stream.cliff_time, end: stream.end_time, }
        }

        /// Returns the refundable amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `refundable_amount` - The refundable amount of the stream.
        fn get_refunded_amount(self: @ContractState, stream_id: u64) -> u256 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).amounts.refunded
        }

        /// Returns the status of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `status` - The status of the stream.
        /// # Note
        /// * `PENDING` - The stream is pending - 0
        /// * `STREAMING` - The stream is streaming - 1
        /// * `CANCELED` - The stream is canceled - 2
        /// * `SETTLED` - The stream is settled - 3
        /// * `DEPLETED` - The stream is depleted - 4
        fn status_of(self: @ContractState, stream_id: u64) -> Status {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            TokeiInternalImpl::_status_of(self, stream_id)
        }


        /// Returns the amount of tokens streamed.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `streamed_amount` - The amount of tokens streamed.
        fn streamed_amount_of(self: @ContractState, stream_id: u64) -> u256 {
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
        fn get_stream(self: @ContractState, stream_id: u64) -> LockupLinearStream {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let stream = self.streams.read(stream_id);

            if (TokeiInternalImpl::_status_of(self, stream_id) == Status::SETTLED) {
                let stream_updated = LockupLinearStream {
                    stream_id: stream.stream_id,
                    sender: stream.sender,
                    asset: stream.asset,
                    recipient: stream.recipient,
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

                stream_updated
            } else {
                stream
            }
        }

        /// Returns the withdrawn amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn get_withdrawn_amount(self: @ContractState, stream_id: u64) -> u256 {
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
        /// # Returns
        /// * `refundable_amount` - The refundable amount of the stream.
        fn refundable_amount_of(self: @ContractState, stream_id: u64) -> u256 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            if (self.streams.read(stream_id).is_cancelable
                && !self.streams.read(stream_id).is_depleted) {
                self.streams.read(stream_id).amounts.deposited
                    - TokeiInternalImpl::_calculate_streamed_amount(self, stream_id)
            } else {
                0
            }
        }

        /// Returns if the stream was canceled.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `true` - If the stream was canceled.
        fn was_canceled(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.streams.read(stream_id).was_canceled
        }

        /// Returns the recipient address of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `recipient` - The recipient address of the stream.
        fn get_recipient(self: @ContractState, stream_id: u64) -> ContractAddress {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self.erc721.owner_of(stream_id.into())
        }

        /// Returns a bool if the stream was canceled, settled, or depleted.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `true` - If the stream is cold.
        fn is_cold(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let status = TokeiInternalImpl::_status_of(self, stream_id);
            let result = status == Status::CANCELED
                || status == Status::DEPLETED
                || status == Status::SETTLED;
            result
        }

        /// Returns a bool if the stream is streaming or pending.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `true` - If the stream is warm.
        fn is_warm(self: @ContractState, stream_id: u64) -> bool {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let status = TokeiInternalImpl::_status_of(self, stream_id);
            let result = status == Status::PENDING || status == Status::STREAMING;
            result
        }

        /// Returns the withdrawable amount of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// # Returns
        /// * `withdrawable_amount` - The withdrawable amount of the stream.
        fn withdrawable_amount_of(self: @ContractState, stream_id: u64) -> u256 {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            self._withdrawable_amount_of(stream_id)
        }

        /// Returns the amount of protocol revenues for the given asset.
        /// # Arguments
        /// * `asset` - The asset to claim the protocol revenues for.
        /// # Returns
        /// * `protocol_revenues` - The amount of protocol revenues for the given asset.
        fn get_protocol_revenues(self: @ContractState, asset: ContractAddress) -> u256 {
            assert(Zeroable::is_non_zero(asset), 'Invalid asset');
            self.protocol_revenues.read(asset)
        }

        /// Returns the protocol fee for the given asset.
        /// # Arguments
        /// * `asset` - The asset that has a set protocol fee.
        /// # Returns
        /// * `protocol_fee` - The protocol fee for the given asset.
        fn get_protocol_fee(self: @ContractState, asset: ContractAddress) -> u256 {
            self.protocol_fee.read(asset)
        }

        /// Returns the NFT descriptor address.
        /// # Returns
        /// * `nft_descriptor` - The NFT descriptor address.
        fn get_nft_descriptor(self: @ContractState) -> ContractAddress {
            self.nft_descriptor.read()
        }

        /// Returns the flash fee
        /// # Returns
        /// * `flash_fee` - The flash fee.
        fn get_flash_fee(self: @ContractState) -> u256 {
            self.flash_fee.read()
        }

        /// Returns the admin address.
        /// # Returns
        /// * `admin` - The admin address.
        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }

        /// Returns the streams of the sender.
        /// # Arguments
        /// * `sender` - The address of the sender.
        /// # Returns
        /// * `streams` - The streams of the sender.
        fn get_streams_by_sender(
            self: @ContractState, sender: ContractAddress
        ) -> Array<LockupLinearStream> {
            let max_stream_id = self.next_stream_id.read();
            let mut streams: Array<LockupLinearStream> = ArrayTrait::new();
            let mut i = 1; //Since the stream id starts from 1
            loop {
                if i >= max_stream_id {
                    break;
                }
                let stream = self.streams.read(i);
                if stream.sender == sender {
                    streams.append(stream);
                }
                i += 1;
            };
            streams
        }

        /// Returns the streams of the recipient.
        /// # Arguments
        /// * `recipient` - The address of the recipient.
        /// # Returns
        /// * `streams` - The streams of the recipient.
        fn get_streams_by_recipient(
            self: @ContractState, recipient: ContractAddress
        ) -> Array<LockupLinearStream> {
            let max_stream_id = self.next_stream_id.read();
            let mut streams: Array<LockupLinearStream> = ArrayTrait::new();
            let mut i = 1; //Since the stream id starts from 1
            loop {
                if i >= max_stream_id {
                    break;
                }
                let stream = self.streams.read(i);
                if stream.recipient == recipient {
                    streams.append(stream);
                }
                i += 1;
            };
            streams
        }

        /// Returns the streams ids of the sender.
        /// # Arguments
        /// * `sender` - The address of the sender.
        /// # Returns
        /// * `stream_ids` - The stream ids of the sender.
        fn get_streams_ids_by_sender(self: @ContractState, sender: ContractAddress) -> Array<u64> {
            let max_stream_id = self.next_stream_id.read();
            let mut stream_ids: Array<u64> = ArrayTrait::new();
            let mut i = 1; // As the stream id starts from 1
            loop {
                if i >= max_stream_id {
                    break;
                }
                let stream = self.streams.read(i);
                if (stream.sender == sender) {
                    stream_ids.append(i);
                }

                i += 1;
            };
            stream_ids
        }

        /// Returns the streams ids of the recipient.
        /// # Arguments
        /// * `recipient` - The address of the recipient.
        /// # Returns
        /// * `stream_ids` - The stream ids of the recipient.
        fn get_streams_ids_by_recipient(
            self: @ContractState, recipient: ContractAddress
        ) -> Array<u64> {
            let max_stream_id = self.next_stream_id.read();
            let mut stream_ids: Array<u64> = ArrayTrait::new();
            let mut i = 1; // As the stream id starts from 1
            loop {
                if i >= max_stream_id {
                    break;
                }
                let stream = self.streams.read(i);
                if (stream.recipient == recipient) {
                    stream_ids.append(i);
                }

                i += 1;
            };
            stream_ids
        }


        /// Creates a new stream with a given range.
        /// # Arguments
        /// * `sender` - The address streaming the assets, with the ability to cancel the stream.
        /// * `recipient` - The address receiving the assets.
        /// * `total_amount` - The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
        /// * `asset` - The contract address of the ERC-20 asset used for streaming.
        /// * `cancelable` - Indicates if the stream is cancelable.
        /// * `transferable` - Indicates if the stream is transferable.
        /// * `range` - The range of the stream. Struct containing (i) the stream's start time, (ii) cliff time, and (iii) end time, all as Unix
        /// * `broker` - The broker of the stream.  Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the percentage fee paid to the broker from `totalAmount`.
        /// # Returns
        /// * `stream_id` - The id of the stream.
        fn create_with_range(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            total_amount: u256,
            asset: ContractAddress,
            cancelable: bool,
            transferable: bool,
            range: Range,
            broker: Broker,
        ) -> u64 {
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

        /// Creates a new stream with a given duration.
        /// # Arguments
        /// * `sender` - The address streaming the assets, with the ability to cancel the stream.
        /// * `recipient` - The address receiving the assets.
        /// * `total_amount` - The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
        /// * `asset` - The contract address of the ERC-20 asset used for streaming.
        /// * `cancelable` - Indicates if the stream is cancelable.
        /// * `transferable` - Indicates if the stream is transferable.
        /// * `duration` - The duration of the stream. Struct containing (i) the stream's cliff period, (ii) total duration
        /// * `broker` - The broker of the stream.  Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the percentage fee paid to the broker from `totalAmount`.
        /// # Returns
        /// * `stream_id` - The id of the stream.
        fn create_with_duration(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            total_amount: u256,
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

        /// Burns the NFT token of the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn burn_token(ref self: ContractState, stream_id: u64) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(self.is_depleted(stream_id), STREAM_NOT_DEPLETED);
            assert(
                TokeiInternalImpl::_is_caller_stream_recipient_or_approved(@self, stream_id),
                LOCKUP_UNAUTHORIZED
            );

            self.erc721._burn(stream_id.into());
        }

        /// Cancels the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn cancel(ref self: ContractState, stream_id: u64) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(!self.is_depleted(stream_id), STREAM_DEPLETED);
            assert(!self.was_canceled(stream_id), STREAM_CANCELED);
            let value = TokeiInternalImpl::_is_caller_stream_sender(@self, stream_id);
            assert(
                value || get_caller_address() == self.get_recipient(stream_id), LOCKUP_UNAUTHORIZED
            );

            TokeiInternalImpl::_cancel(ref self, stream_id);
        }

        /// Cancels multiple streams.
        /// # Arguments
        /// * `stream_ids` - The ids of the streams.
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

        /// Renounces the stream.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        fn renounce(ref self: ContractState, stream_id: u64) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            let status = self._status_of(stream_id);
            assert(status != Status::DEPLETED, STREAM_DEPLETED);
            assert(status != Status::CANCELED, STREAM_CANCELED);
            assert(status != Status::SETTLED, STREAM_SETTLED);
            assert(self._is_caller_stream_sender(stream_id), LOCKUP_UNAUTHORIZED);

            self._renounce(stream_id);
        }

        /// Sets the NFT descriptor.
        /// # Arguments
        /// * `nft_descriptor` - The NFT descriptor.
        fn set_nft_descriptor(ref self: ContractState, nft_descriptor: ContractAddress) {
            assert(Zeroable::is_non_zero(nft_descriptor), 'Invalid nft descriptor');
            self.assert_only_admin();
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

        /// Withdraws the stream's assets.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// * `to` - The address to withdraw the assets to.
        /// * `amount` - The amount of assets to withdraw.
        fn withdraw(ref self: ContractState, stream_id: u64, to: ContractAddress, amount: u256) {
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(Zeroable::is_non_zero(amount), WITHDRAW_ZERO_AMOUNT);
            assert(to != Zeroable::zero(), WITHDRAW_TO_ZERO_ADDRESS);
            assert(!self.is_depleted(stream_id), STREAM_DEPLETED);

            let value = TokeiInternalImpl::_is_caller_stream_sender(@self, stream_id);

            assert(
                value
                    || TokeiInternalImpl::_is_caller_stream_recipient_or_approved(@self, stream_id),
                LOCKUP_UNAUTHORIZED
            );

            let recipient = self.get_recipient(stream_id);
            assert(to == recipient, INVALID_SENDER_WITHDRAWAL);

            TokeiInternalImpl::_withdraw(ref self, stream_id, to, amount);
        }

        /// Withdraws maximum amount of the stream's assets.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// * `new_recipient` - The address to withdraw the assets to.
        fn withdraw_max(ref self: ContractState, stream_id: u64, to: ContractAddress) {
            self.withdraw(stream_id, to, self.withdrawable_amount_of(stream_id));
        }

        /// Withdraws maximum amount of the stream's assets and transfers the NFT to a new recipient.
        /// # Arguments
        /// * `stream_id` - The id of the stream.
        /// * `new_recipient` - The address to withdraw the assets to.
        fn withdraw_max_and_transfer(
            ref self: ContractState, stream_id: u64, new_recipient: ContractAddress
        ) {
            let current_recipient = self.get_recipient(stream_id);
            assert(self.is_transferable(stream_id), 'Stream is not transferable');
            assert(Zeroable::is_non_zero(stream_id), 'Invalid stream id');
            assert(Zeroable::is_non_zero(new_recipient), 'Invalid new_recipient');
            assert(get_caller_address() == current_recipient, LOCKUP_UNAUTHORIZED);
            let withdrawable_amount = self.withdrawable_amount_of(stream_id);
            if (withdrawable_amount > 0) {
                self.withdraw(stream_id, current_recipient, withdrawable_amount);
            }

            self.erc721.transfer_from(current_recipient, new_recipient, stream_id.into());
        }

        /// Withdraws multiple streams' assets.
        /// # Arguments
        /// * `stream_ids` - The ids of the streams.
        /// * `to` - The address to withdraw the assets to.
        /// * `amounts` - The amounts of assets to withdraw.
        fn withdraw_multiple(
            ref self: ContractState, stream_ids: Span<u64>, to: ContractAddress, amounts: Span<u256>
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

        /// Sets the flash fee.
        /// # Arguments
        /// * `new_flash_fee` - The new flash fee.
        fn set_flash_fee(ref self: ContractState, new_flash_fee: u256) {
            self.assert_only_admin();
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

        /// Sets the protocol fee.
        /// # Arguments
        /// * `asset` - The asset to set the protocol fee for.
        /// * `new_protocol_fee` - The new protocol fee.
        fn set_protocol_fee(
            ref self: ContractState, asset: ContractAddress, new_protocol_fee: u256
        ) {
            self.assert_only_admin();
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

        /// Toggles the flash asset flag.
        /// # Arguments
        /// * `asset` - The asset to toggle the flash asset flag for.
        fn toggle_flash_assets(ref self: ContractState, asset: ContractAddress) {
            self.assert_only_admin();
            let old_flag = self.is_flash_asset.read(asset);
            self.is_flash_asset.write(asset, !old_flag);

            self
                .emit(
                    ToggleFlashAsset {
                        admin: self.admin.read(), asset: asset, new_flag: !old_flag,
                    }
                );
        }

        /// Transfers the admin.
        /// # Arguments
        /// * `new_admin` - The new admin.
        fn transfer_admin(ref self: ContractState, new_admin: ContractAddress) {
            self.assert_only_admin();
            let old_admin = self.admin.read();
            self.admin.write(new_admin);

            self.emit(TransferAdmin { old_admin: old_admin, new_admin: new_admin, });
        }

        /// Claims the protocol revenues for the given asset.
        /// # Arguments
        /// * `asset` - The asset to claim the protocol revenues for.
        fn claim_protocol_revenues(ref self: ContractState, asset: ContractAddress) {
            self.assert_only_admin();
            let protocol_revenues = self.protocol_revenues.read(asset);
            assert(protocol_revenues > 0, NO_PROTOCOL_REVENUE);

            self.protocol_revenues.write(asset, 0);

            ERC20ABIDispatcher { contract_address: asset }
                .transfer(self.admin.read(), protocol_revenues.into());

            self
                .emit(
                    ClaimProtocolRevenues {
                        admin: self.admin.read(), asset: asset, amount: protocol_revenues
                    }
                );
        }
    }

    #[abi(embed_v0)]
    impl SnakeTokeiLockupLinearERC721 of ITokeiLockupLinearERC721Snake<ContractState> {
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.erc721.balance_of(account)
        }

        fn owner_of(self: @ContractState, token_id: u128) -> ContractAddress {
            self.erc721.owner_of(token_id.into())
        }

        fn get_approved(self: @ContractState, token_id: u128) -> ContractAddress {
            self.erc721.get_approved(token_id.into())
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.erc721.is_approved_for_all(owner, operator)
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u128) {
            self.erc721.approve(to, token_id.into());
        }
        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            self.erc721.set_approval_for_all(operator, approved);
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u128
        ) {
            self.erc721.transfer_from(from, to, token_id.into());
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u128,
            data: Span<felt252>
        ) {
            self.erc721.safe_transfer_from(from, to, token_id.into(), data);
        }
    }

    #[abi(embed_v0)]
    impl CamelITokeiLockupLinearERC721 of ITokeiLockupLinearERC721Camel<ContractState> {
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            self.erc721.balance_of(account)
        }
        fn ownerOf(self: @ContractState, token_id: u128) -> ContractAddress {
            self.erc721.owner_of(token_id.into())
        }
        fn getApproved(self: @ContractState, token_id: u128) -> ContractAddress {
            self.erc721.get_approved(token_id.into())
        }
        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.erc721.is_approved_for_all(owner, operator)
        }
        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            self.erc721.set_approval_for_all(operator, approved);
        }
        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u128
        ) {
            self.erc721.transfer_from(from, to, token_id.into());
        }
        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u128,
            data: Span<felt252>
        ) {
            self.erc721.safe_transfer_from(from, to, token_id.into(), data);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    ///INTERNAL CONSTANT FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    #[generate_trait]
    impl TokeiInternalImpl of TokeiInternalTrait {
        // Assertion that caller is the admin.
        fn assert_only_admin(self: @ContractState) {
            assert(get_caller_address() == self.admin.read(), LOCKUP_UNAUTHORIZED);
        }

        // Calculates the streamed amount of the stream.
        // # Arguments
        // * `stream_id` - The id of the stream.
        // # Returns
        // * `streamed_amount` - The streamed amount of the stream.
        fn _calculate_streamed_amount(self: @ContractState, stream_id: u64) -> u256 {
            let cliff_time = self.streams.read(stream_id).cliff_time;
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
            let elapsed_time_percentage = scaled_down_div(elapsed_time, total_time);

            let deposited_amount = self.streams.read(stream_id).amounts.deposited;
            // Convert the percentage to a felt252 and then to a u128.
            let elapsed_time_percentage_felt: felt252 = elapsed_time_percentage.into();
            let elapsed_time_percentage_u256: u256 = elapsed_time_percentage_felt.into();

            // Multiply the deposited amount by the percentage.
            let _streamed_amount = deposited_amount * elapsed_time_percentage_u256;
            let streamed_amount = _streamed_amount / 100;

            // Although the streamed amount should never exceed the deposited amount, this condition is checked
            // without asserting to avoid locking funds in case of a bug. If this situation occurs, the withdrawn
            // amount is considered to be the streamed amount, and the stream is effectively frozen.
            if (streamed_amount > deposited_amount) {
                return self.streams.read(stream_id).amounts.withdrawn;
            }

            return streamed_amount;
        }

        // Retuns the status of the stream.
        // # Arguments
        // * `stream_id` - The id of the stream.
        // # Returns
        // * `status` - The status of the stream.
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

        // Withdraws the stream's deposited amount to the recipient.
        // # Arguments
        // * `stream_id` - The id of the stream.
        // * `to` - The recipient of the withdrawn amount.
        // * `amount` - The amount to withdraw.
        fn _withdraw(ref self: ContractState, stream_id: u64, to: ContractAddress, amount: u256) {
            // Calculates the amount that can be withdrawn.
            let withdrawable_amount = self._withdrawable_amount_of(stream_id);
            assert(amount <= withdrawable_amount, OVERDRAW);
            let stream = self.streams.read(stream_id);
            let stream_updated = LockupLinearStream {
                stream_id: stream.stream_id,
                sender: stream.sender,
                asset: stream.asset,
                recipient: stream.recipient,
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

            let amounts = self.streams.read(stream_id).amounts;

            if (amounts.withdrawn >= amounts.deposited - amounts.refunded) {
                let _stream_updated = LockupLinearStream {
                    stream_id: stream.stream_id,
                    sender: stream.sender,
                    asset: stream.asset,
                    recipient: stream.recipient,
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
            ERC20ABIDispatcher { contract_address: asset }.transfer(to, amount.into());
            self.emit(WithdrawFromLockupStream { stream_id, to, asset, amount, });
        }

        // Renounces the stream.
        // # Arguments
        // * `stream_id` - The id of the stream.
        fn _renounce(ref self: ContractState, stream_id: u64) {
            let stream = self.streams.read(stream_id);
            // Checks: the stream is cancelable.
            assert(stream.is_cancelable, STREAM_NOT_CANCELABLE);
            let stream_updated = LockupLinearStream {
                stream_id: stream.stream_id,
                sender: stream.sender,
                asset: stream.asset,
                recipient: stream.recipient,
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
            // Emit an event for the renounced stream.
            self.emit(RenounceLockupStream { stream_id });
        }

        // Cancels the stream.
        // # Arguments
        // * `stream_id` - The id of the stream.
        fn _cancel(ref self: ContractState, stream_id: u64) {
            // Calculates the streamed amount of the stream.
            let streamed_amount = TokeiInternalImpl::_calculate_streamed_amount(@self, stream_id);

            let amounts = self.streams.read(stream_id).amounts;
            // Checks: if the amount deposited is greater than the streamed amount.    
            assert(streamed_amount < amounts.deposited, STREAM_SETTLED);
            // Checks: if the stream is cancelable.
            assert(self.streams.read(stream_id).is_cancelable, STREAM_NOT_CANCELABLE);

            // Calculates the refundable amount of the stream.
            let sender_amount = amounts.deposited - streamed_amount;
            let recipient_amount = streamed_amount - amounts.withdrawn;
            let stream = self.streams.read(stream_id);

            if (recipient_amount == 0) {
                let stream_updated = LockupLinearStream {
                    stream_id: stream.stream_id,
                    sender: stream.sender,
                    asset: stream.asset,
                    recipient: stream.recipient,
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
            } else {
                let stream_updated = LockupLinearStream {
                    stream_id: stream.stream_id,
                    sender: stream.sender,
                    asset: stream.asset,
                    recipient: stream.recipient,
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
            }

            let sender = stream.sender;
            let recipient = self.get_recipient(stream_id);
            // Interactions: transfer the refundable amount from the protocol's contract to the stream sender.
            ERC20ABIDispatcher { contract_address: stream.asset }
                .transfer(sender, sender_amount.into());

            // Emit an event for the canceled stream.
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
        }

        // Returns the withdrawable amount of the stream.
        // # Arguments
        // * `stream_id` - The id of the stream.
        // # Returns
        // * The withdrawable amount of the stream.
        fn _withdrawable_amount_of(self: @ContractState, stream_id: u64) -> u256 {
            TokeiInternalImpl::_streamed_amount_of(self, stream_id)
                - self.streams.read(stream_id).amounts.withdrawn
        }


        // Returns the streamed amount of the stream.
        // # Arguments
        // * `stream_id` - The id of the stream.
        // # Returns
        // * The streamed amount of the stream.
        fn _streamed_amount_of(self: @ContractState, stream_id: u64) -> u256 {
            let stream = self.streams.read(stream_id);
            let amounts = stream.amounts;

            if (stream.is_depleted) {
                return amounts.withdrawn;
            } else if (stream.was_canceled) {
                return amounts.deposited - amounts.refunded;
            }

            TokeiInternalImpl::_calculate_streamed_amount(self, stream_id)
        }

        // Checks if the caller is the stream sender.
        // # Arguments
        // * `stream_id` - The id of the stream.
        // # Returns
        // * `true` if the caller is the stream sender.
        fn _is_caller_stream_sender(self: @ContractState, stream_id: u64) -> bool {
            let stream = self.streams.read(stream_id);
            get_caller_address() == stream.sender
        }


        // Creates a new stream with the given parameters.
        // # Arguments
        // * `sender` - The address of the stream sender.
        // * `recipient` - The address of the stream recipient.
        // * `total_amount` - The total amount of the stream.
        // * `asset` - The address of the asset to be streamed.
        // * `cancelable` - Whether the stream is cancelable.
        // * `transferable` - Whether the stream is transferable.
        // * `range` - The range of the stream.
        // * `broker` - The broker of the stream.
        // # Returns
        // * The stream id of the newly created stream.
        fn _create_with_range(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            total_amount: u256,
            asset: ContractAddress,
            cancelable: bool,
            transferable: bool,
            range: Range,
            broker: Broker,
        ) -> u64 {
            let protocol_fee = self.protocol_fee.read(asset);

            let create_amounts = check_and_calculate_fees(
                total_amount, protocol_fee, broker.fee, MAX_FEE
            );

            // Checks: check the fees and calculate the fee amounts.
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

            // Creating the LockupAmounts struct
            let amounts: LockupAmounts = LockupAmounts {
                deposited: create_amounts.deposit, withdrawn: 0, refunded: 0,
            };

            // Effects: create the stream.
            let stream = LockupLinearStream {
                stream_id: stream_id,
                sender,
                asset,
                recipient,
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

            // Effects: update the protocol revenues.
            let protocol_revenue = self.protocol_revenues.read(asset) + create_amounts.protocol_fee;
            self.protocol_revenues.write(asset, protocol_revenue);

            let res = self.protocol_revenues.read(asset);

            // Effects: mint the NFT to the recipient.
            self.erc721._mint(recipient, stream_id.into());

            // Interactions: transfer the deposited amount from the caller to the protocol's contract.
            ERC20ABIDispatcher { contract_address: asset }
                .transfer_from(caller, this, amounts.deposited);

            // Interactions: pay the broker fee, if not zero.
            if (broker.fee > 0) {
                ERC20ABIDispatcher { contract_address: asset }
                    .transfer_from(caller, broker.account, create_amounts.broker_fee);
            }

            // Emit an event for the newly created stream.
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

        // Checks if the caller is the stream recipient or an approved operator.
        // # Arguments
        // * `stream_id` - The id of the stream.
        // # Returns
        // * `true` if the caller is the stream recipient or an approved operator.
        fn _is_caller_stream_recipient_or_approved(self: @ContractState, stream_id: u64) -> bool {
            let stream_id_u256: u256 = stream_id.into();
            let recipient = self.get_recipient(stream_id);

            return get_caller_address() == recipient
                || self.erc721.get_approved(stream_id_u256) == get_caller_address()
                || self.erc721.is_approved_for_all(recipient, get_caller_address());
        }
    }
}

