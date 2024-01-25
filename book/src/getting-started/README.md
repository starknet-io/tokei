# Getting Started with Tokei Lockup Linear Contract
Welcome to the Tokei Lockup Linear Contract on StarkNet. This guide will provide you with all the necessary information to get started with building, testing, and interacting with the contract, as well as administering it effectively.

## 📝Table of Contents
- [Prerequisites](#prerequisites)
- [Building the Contracts](#building-the-contracts)
- [Testing the Contracts](#testing-the-contracts)
- [User Interaction CLI Tool](#user-interaction-cli-tool)
- [Admin Interaction Script](#admin-interaction-script)

## 📖Prerequisites
Before you begin, make sure you have the following prerequisites installed:

- Starknet Foundry
- Scarb
- Starknet.js
- Node.js (for User and Admin scripts)
- TypeScript

  

More details: [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/)

## 🏗️ Building the Contracts
To build the smart contracts, open a terminal and execute:

```bash
scarb build
```
This command will compile the smart contracts and output them to the target directory. For a detailed structure of the output, see [build.md]((https://github.com/Akashneelesh/tokei/blob/main/book/src/getting-started/build.md)).

## 🔨Testing the Contracts
Run the following command to test the contracts:
```bash
snforge test
```
This executes tests located in the tests directory. Sample output:

```
Collected 38 test(s) from tokei package
Running 38 test(s) from src/
[PASS] tokei::tests::... (detailed test results)
```

For more detailed view about the test cases see [test.md](https://github.com/Akashneelesh/tokei/blob/main/book/src/getting-started/test.md).

## ⚙ User Interaction CLI Tool
The User Interaction CLI tool is designed for easy interaction with the streaming contract. It supports various functionalities such as creating streams, withdrawing funds, and querying stream details. To use this tool, you need to install certain dependencies and follow the steps outlined in [user.md](https://github.com/Akashneelesh/tokei/blob/main/book/src/getting-started/user.md).

### Key functionalities include:

- Stream creation and management
- Asset management
- Fee and NFT integration

For detailed instructions on installation, usage, and examples, please refer to [user.md](https://github.com/Akashneelesh/tokei/blob/main/book/src/getting-started/user.md).

## 👮‍♂️ Admin Interaction Script
The Admin Interaction Script facilitates the management of the Tokei Lockup Linear Contract. It includes features for setting and retrieving protocol fees, claiming protocol revenues, and viewing administrative details.

### Key aspects include:
- Stream creation and management
- Fee handling
- NFT Integration
- Core functionalities and key structures
For complete guidelines on installation, usage, and available functions, see [admin.md](https://github.com/Akashneelesh/tokei/blob/main/book/src/getting-started/admin.md).

## 📚 Resources

Here are some resources to help you get started:

- [Cairo Book](https://book.cairo-lang.org/)
- [Starknet Book](https://book.starknet.io/)
- [Starknet Foundry Book](https://foundry-rs.github.io/starknet-foundry/)
- [Starknet By Example](https://starknet-by-example.voyager.online/)
- [Starkli Book](https://book.starkli.rs/)

## 📖 License

This project is licensed under the **MIT license**. See [LICENSE](LICENSE) for more information.
