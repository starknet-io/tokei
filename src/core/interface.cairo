use starknet::ContractAddress;

#[starknet::interface]
trait ITokeiLockupLinearERC721Snake<TContractState> {
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;

    fn owner_of(self: @TContractState, token_id: u128) -> ContractAddress;

    fn get_approved(self: @TContractState, token_id: u128) -> ContractAddress;

    fn is_approved_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u128);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);

    fn transfer_from(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u128
    );

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
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn ownerOf(self: @TContractState, token_id: u128) -> ContractAddress;
    fn getApproved(self: @TContractState, token_id: u128) -> ContractAddress;
    fn isApprovedForAll(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn setApprovalForAll(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn transferFrom(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u128
    );
    fn safeTransferFrom(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u128,
        data: Span<felt252>
    );
}
