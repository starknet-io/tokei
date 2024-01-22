use starknet::ContractAddress;

#[derive(Drop, Copy, Serde)]
struct Users {
    admin: ContractAddress,
    alice: ContractAddress,
    broker: ContractAddress,
    eve: ContractAddress,
    operator: ContractAddress,
    recipient: ContractAddress,
    sender: ContractAddress,
}
