mod Base_Test {
    use core::array::ArrayTrait;
    use starknet::{ContractAddress, contract_address_const};
    use integer::BoundedInt;
    use tokei::tokens::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use snforge_std::{
        declare, ContractClassTrait, start_prank, stop_prank, RevertedTransaction, CheatTarget,
        TxInfoMock,
    };

    use tokei::tests::utils::defaults::Defaults::{PROTOCOL_FEES};
    use tokei::tests::utils::defaults::Defaults;

    use tokei::tests::utils::utils::Utils::{pow_256, ADMIN};
    use tokei::core::lockup_linear::{
        ITokeiLockupLinearDispatcher, ITokeiLockupLinearDispatcherTrait
    };

    use debug::PrintTrait;
// fn setup() -> (
//     ContractAddress,
//     ContractAddress,
//     ContractAddress,
//     ContractAddress,
//     ITokeiLockupLinearDispatcher
// ) {
//     let admin = contract_address_const::<'admin'>();
//     let owner = contract_address_const::<'owner'>();
//     let sender = contract_address_const::<'sender'>();
//     let recipient = contract_address_const::<'recipient'>();
//     let alice = contract_address_const::<'alice'>();
//     let eve = contract_address_const::<'eve'>();

//     // let (token_dispatcher, token_addr) = deploy_setup_erc20(
//     //     'Dai Stable', 'DAI', BoundedInt::max(), owner
//     // );

//     let (tokei, tokei_addr) = setup_tokei(admin);

//     let addresses = array![owner, sender, recipient, alice, eve];
//     // give_tokens_and_approve(addresses, token_addr, token_dispatcher, owner, tokei_addr);

//     let stream_id = tokei.get_next_stream_id();
//     stream_id.print();
//     (admin, sender, recipient, recipient, tokei)
// }

// fn setup_tokei(admin: ContractAddress) -> (ITokeiLockupLinearDispatcher, ContractAddress) {
//     // Setup the contracts.
//     let (tokei_addr, tokei,) = deploy_tokei();
//     // Prank the caller address.
//     prepare_contracts(admin, tokei,);

//     // Return the caller address and the contract interfaces.
//     (tokei, tokei.contract_address)
// }

// fn prepare_contracts(admin: ContractAddress, tokei: ITokeiLockupLinearDispatcher,) {
//     // Prank the caller address for calls to `TokeiLockupLinear` contract.
//     start_prank(CheatTarget::One(tokei.contract_address), admin);
// }

// fn teardown(tokei: ITokeiLockupLinearDispatcher,) {
//     stop_prank(CheatTarget::One(tokei.contract_address));
// }

// #[test]
// fn test_set_protocol_fee() {
//     let (admin, _, _, _, tokei) = setup();
//     let token_addr = contract_address_const::<10>();
//     let protocol_fee = 1000 * pow_128(10, 18);

//     // prepare_contracts(admin, tokei);

//     // tokei.set_protocol_fee(token_addr, protocol_fee);

//     // let actual_protocol_fee = tokei.get_protocol_fee(token_addr);

//     // teardown(tokei);
//     let res = tokei.get_admin();
//     admin.print();
//     res.print();

//     assert(admin == res, 'Invalid address');
// }
// #[test]
// fn create_default_stream_with_range(
//     recipient_address: ContractAddress, tokei: ITokeiLockupLinearDispatcher
// ) {
//     let (_, sender, _, asset, _) = setup();
//     let recipient_address = contract_address_const::<0>();
//     // let (_, recipient, total_amount, _, cancelable, transferable, range, broker) =
//     //     Defaults::create_with_range();
//     start_prank(CheatTarget::One(tokei.contract_address), sender);

//     // let stream_id = tokei
//     //     .create_with_range(
//     //         sender,
//     //         recipient_address,
//     //         total_amount,
//     //         asset,
//     //         cancelable,
//     //         transferable,
//     //         range,
//     //         broker,
//     //     );
//     // stop_prank(CheatTarget::One(tokei.contract_address));

//     assert(1 == 2, 'Invalid StreamId');
// }
}

