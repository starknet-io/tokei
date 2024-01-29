use starknet::ContractAddress;


#[starknet::interface]
trait ITokeiLockupLinearERC721Snake<TContractState> {
    /// Returns the number of NFTs owned by `account`.
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;

    /// Returns the owner address of `token_id`.
    ///
    /// Arguements:
    ///
    /// - `token_id` exists.
    fn owner_of(self: @TContractState, token_id: u128) -> ContractAddress;

    /// Returns the address approved for `token_id`.
    ///
    /// Arguements:
    ///
    /// - `token_id` exists.
    fn get_approved(self: @TContractState, token_id: u128) -> ContractAddress;

    /// Query if `operator` is an authorized operator for `owner`.
    fn is_approved_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;

    /// Change or reaffirm the approved address for an NFT.
    ///
    /// Arguements:
    ///
    /// - The caller is either an approved operator or the `token_id` owner.
    /// - `to` cannot be the token owner.
    /// - `token_id` exists.
    ///
    /// Emits an `Approval` event.
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u128);

    /// Enable or disable approval for `operator` to manage all of the
    /// caller's assets.
    ///
    /// Arguements:
    ///
    /// - `operator` cannot be the caller.
    ///
    /// Emits an `Approval` event.
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);

    /// Transfers ownership of `token_id` from `from` to `to`.
    ///
    /// Arguements:
    ///
    /// - Caller is either approved or the `token_id` owner.
    /// - `to` is not the zero address.
    /// - `from` is not the zero address.
    /// - `token_id` exists.
    ///
    /// Emits a `Transfer` event.
    fn transfer_from(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u128
    );

    /// Transfers ownership of `token_id` from `from` if `to` is either an account or `IERC721Receiver`.
    ///
    /// `data` is additional data, it has no specified format and it is sent in call to `to`.
    ///
    /// Requirements:
    ///
    /// - Caller is either approved or the `token_id` owner.
    /// - `to` is not the zero address.
    /// - `from` is not the zero address.
    /// - `token_id` exists.
    /// - `to` is either an account contract or supports the `IERC721Receiver` interface.
    ///
    /// Emits a `Transfer` event. 
    fn safe_transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u128,
        data: Span<felt252>
    );
}

#[starknet::interface]
trait ITokeiLockupLinearERC721Camel<TContractState> {
    /// Returns the number of NFTs owned by `account`.
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;

    /// Returns the owner address of `token_id`.
    ///
    /// Arguements:
    ///
    /// - `token_id` exists.
    fn ownerOf(self: @TContractState, token_id: u128) -> ContractAddress;

    /// Returns the address approved for `token_id`.
    ///
    /// Arguements:
    ///
    /// - `token_id` exists.
    fn getApproved(self: @TContractState, token_id: u128) -> ContractAddress;

    /// Query if `operator` is an authorized operator for `owner`.
    fn isApprovedForAll(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;

    /// Enable or disable approval for `operator` to manage all of the
    /// caller's assets.
    ///
    /// Arguements:
    ///
    /// - `operator` cannot be the caller.
    ///
    /// Emits an `Approval` event.
    fn setApprovalForAll(ref self: TContractState, operator: ContractAddress, approved: bool);

    /// Transfers ownership of `token_id` from `from` to `to`.
    ///
    /// Arguements:
    ///
    /// - Caller is either approved or the `token_id` owner.
    /// - `to` is not the zero address.
    /// - `from` is not the zero address.
    /// - `token_id` exists.
    ///
    /// Emits a `Transfer` event.
    fn transferFrom(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u128
    );

    /// Transfers ownership of `token_id` from `from` if `to` is either an account or `IERC721Receiver`.
    ///
    /// `data` is additional data, it has no specified format and it is sent in call to `to`.
    ///
    /// Requirements:
    ///
    /// - Caller is either approved or the `token_id` owner.
    /// - `to` is not the zero address.
    /// - `from` is not the zero address.
    /// - `token_id` exists.
    /// - `to` is either an account contract or supports the `IERC721Receiver` interface.
    ///
    /// Emits a `Transfer` event. 
    fn safeTransferFrom(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u128,
        data: Span<felt252>
    );
}
