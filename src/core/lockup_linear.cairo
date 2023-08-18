//! Main contract of Za Warudo protocol.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use core::traits::Into;
use starknet::{ContractAddress, ClassHash};

// Local imports.
use za_warudo::types::lockup_linear::{Range, Broker};

// *************************************************************************
//                  Interface of the `ZaWarudoLockupLinear` contract.
// *************************************************************************
#[starknet::interface]
trait IZaWarudoLockupLinear<TContractState> {
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
mod ZaWarudoLockupLinear {
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
    use za_warudo::types::lockup_linear::{Range, Broker, LockupLinearStream};
    use za_warudo::types::lockup::LockupAmounts;

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
    }


    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl ZaWarudoLockupLinear of super::IZaWarudoLockupLinear<ContractState> {
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
            // Checks: check the fees and calculate the fee amounts.
            // TODO: implement.

            // Read the next stream id from storage.
            let stream_id = self.next_stream_id.read();

            // Checks: check the fees and calculate the fee amounts.
            // TODO: implement.
            let deposited_amount = total_amount - broker.fee;

            // Checks: validate the user-provided parameters.
            // TODO: implement.

            // Effects: create the stream.
            let stream = LockupLinearStream {
                sender,
                asset,
                start_time: range.start,
                end_time: range.end,
                is_cancelable: cancelable,
                was_canceled: false,
                is_depleted: false,
                amounts: LockupAmounts { deposited: deposited_amount, withdrawn: 0, refunded: 0, },
            };
            self.streams.write(stream_id, stream);

            // Effects: bump the next stream id.
            self.next_stream_id.write(stream_id + 1);

            // Effects: mint the NFT to the recipient.
            // TODO: implement.

            // Interactions: transfer the deposit and the protocol fee.
            // TODO: implement.

            // Interactions: pay the broker fee, if not zero.
            // TODO: implement.

            // Emit an event for  the newly created stream.
            // TODO: implement.

            // Return the stream id.
            stream_id
        }
    }
}
