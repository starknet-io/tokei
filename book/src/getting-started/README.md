# Getting Started with Tokei Lockup Linear Contract
Welcome to the Tokei Lockup Linear Contract on StarkNet. This guide will provide you with all the necessary information to get started with building, testing, and interacting with the contract, as well as administering it effectively.

## 📝Table of Contents
- [About Tokei](#about-tokei)
- [Prerequisites](#prerequisites)
- [Building the Contracts](#building-the-contracts)
- [Testing the Contracts](#testing-the-contracts)
- [User Interaction CLI Tool](#user-interaction-cli-tool)
- [Admin Interaction Script](#admin-interaction-script)

## About Tokei
In the digital age where blockchain technology is reshaping financial landscapes, the Tokei protocol emerges as a cutting-edge solution for token streaming. Inspired by Sablier's groundbreaking work, Tokei harnesses the power of Starknet's Layer 2 capabilities to offer a novel and secure approach to token allocation and distribution, setting a new paradigm in decentralized finance (DeFi).

## **The Advent of Tokei: A New Era in Token Streaming**

At its essence, token streaming facilitates the continuous transfer of assets over time. Tokei elevates this concept by providing enhanced flexibility and customizability on Starknet, enabling users to create tailored streams that fit a plethora of financial scenarios.

### **Distinctive Features of Tokei**

- **Linear Lockup Streams**: Tokei's lockup linear streams are designed for a gradual and controlled release of funds, ideal for structured payment plans and corporate vesting schedules.
- **Customization at Its Core**: With adjustable parameters like start and end times, cliff durations, and options for cancelability and transferability, Tokei caters to diverse streaming needs.
- **Integration with ERC Standards**: Tokei supports ERC-20 tokens for streaming transactions and leverages ERC-721 (NFTs) to represent stream ownership, expanding its utility across asset classes.
- **Transparent Fee Structure**: The platform ensures fair dealings with a clear-cut mechanism for protocol fees and brokerage commissions.
- **Administrative Oversight**: Advanced features allow for administrative interventions, including setting fees, claiming revenues, and managing NFT descriptors.

## **A Closer Look at Tokei's Mechanics on Starknet**

Tokei's smart contract infrastructure orchestrates the entire lifecycle of token streams, from their inception to conclusion.

### **Stream Creation**

Participants can initiate streams with specific durations or date ranges, defining the total amount and the type of asset, as well as other bespoke conditions.

### **Stream Management and Oversight**

The protocol provides a suite of functions for obtaining comprehensive details about each stream, such as asset details, key timepoints, deposited sums, and the stream's current state.

### **Stream Conclusion**

Streams can be terminated based on predefined conditions, with the protocol adeptly reallocating funds relative to the amount streamed and the remaining balance.

### **Withdrawals and Ownership Transfers**

Users can withdraw from streams or transfer ownership, facilitated by NFT representations, further emphasizing Tokei's commitment to flexibility and security.

## **Practical Applications and Implications**

Tokei's protocol unlocks a myriad of possibilities within the DeFi ecosystem:

- **Employee Vesting**: For example, enterprises can implement Tokei to distribute tokens to employees systematically, thereby ensuring a transparent vesting journey.
- **Subscription Services**: Businesses can adopt token streaming as a payment method for subscription services, providing a seamless transaction flow.
- **DAO Operations**: DAOs can employ Tokei to regulate ongoing contributions and distributions, enhancing community engagement and financial management.

## **Visualizing Token Streaming with Tokei**

Let's visualize the process with an example:

- **Scenario**: Evelyn wishes to stream 10,000 XYZ tokens to Jordan over three months.
- **Execution**: She locks the XYZ tokens into Tokei's smart contract at the start of April, with the stream set to end in July.
- **Token Accrual**: As the days of April unfold, Jordan's balance begins to grow in real-time.
- **Withdrawal Option**: By the 10th of April, Jordan has access to a portion of the tokens and can choose to withdraw at any time.

*The graph here depicts a consistent token stream without a cliff.*

<img width="528" alt="Screenshot 2024-01-25 at 11 35 54 PM" src="https://github.com/Akashneelesh/tokei/assets/66639153/68abfa36-3117-452c-87b7-d0e1a73e6d95">


Should Evelyn choose to retract her tokens, she has the autonomy to cancel the stream and retrieve the unstreamed tokens.

### **Introducing Cliffs for Enhanced Control**

Tokei introduces the concept of cliffs to add a strategic pause in the token release schedule:

- **Vesting with Cliffs**: Consider a business that sets a 6-month cliff for an employee's token vesting, followed by a 2-year linear stream. If the employee exits the company prematurely, the business can cancel the stream and secure the assets not yet streamed.

*This graph showcases a Lockup Linear stream with a cliff. The horizontal plateau represents the cliff duration, after which the linear increase in streamed tokens resumes.*

<img width="522" alt="Screenshot 2024-01-25 at 11 36 06 PM" src="https://github.com/Akashneelesh/tokei/assets/66639153/b787c0f0-38a6-42e3-af83-d9233d81bd4e">


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
