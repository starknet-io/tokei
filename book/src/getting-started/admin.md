# StarkNet Admin Interaction Script

## 🔍 Overview

The Tokei Lockup Linear Contract on StarkNet facilitates the creation and management of time-bound asset streams. This guide delves into the functionalities, fee structures, and key contract components like `Durations`, `Range`, `Broker`, and `LockupLinearStream`.
The Tokei Lockup Linear Contract offers a comprehensive solution for asset distribution on StarkNet. Its sophisticated structures enable precise control over asset streaming, making it an essential tool for DeFi applications. A deep understanding of its fee calculations and time-bound mechanisms is key for effective implementation.

## 💪 Core Functionalities

### Stream Creation and Management

- Create asset streams with specific timings using the `Range` structure.
- Support for cancelable and transferable streams.
- Functions for withdrawing assets according to the stream schedule.

### Fee Handling

- Management of protocol and broker fees based on the total stream amount.
- Limitations to prevent excessive fee charges.

### NFT Integration

- Representation of each asset stream as an NFT for ease of tracking and transferability.

## 🔑 Key Structures and Functions

### Fee Calculation (`check_and_calculate_fees`)

- **Inputs**: Total stream amount, protocol fee percentage, broker fee percentage, max fee limit.
- **Outputs**: Calculated deposit, protocol fee, and broker fee in `CreateAmounts` struct.
- **Process**:
  - Validation of protocol and broker fees against the maximum fee limit.
  - Calculation of absolute fee amounts.
  - Verification that total amount covers both fees, with remainder as the deposit amount.

### PercentageMath Trait

- Utilized for calculating fee percentages as a proportion of the total amount.

### Scaled Division (`scaled_down_div`)

- Function for dividing with scaling, used in time-related calculations.

### Range and Durations

- **Range**: Defines timestamps for the start, cliff, and end of an asset stream.
- **Durations**: Represents cliff and total duration in time units.

### LockupLinearStream Structure

- Represents an asset stream, including financial tracking through `LockupAmounts`.
- **LockupAmounts**: Encapsulates deposited, withdrawn, and refunded amounts.

### Validation Checks (`check_create_with_range`)

- Ensures timing integrity and deposit amount of the stream.
- Checks for valid timing sequence and that current time precedes the end time.

## Features
- Setting and retrieving protocol fees
- Claiming protocol revenues
- Viewing administrative details
- Dynamic interaction with smart contracts

## 🏗️ Prerequisites
Before running this script, ensure you have the following installed:
- Node.js and npm
- StarkNet libraries and ethers.js
- TypeScript and ts-node

## ⚙️ Installation
To set up the script on your local machine, follow these steps:
1. Clone the GitHub repository:
2. Navigate to the repository directory and install the required dependencies:

```bash
npm install or yarn
```

## 🛠️ Build the contracts
```bash
scarb build
```

## 🤺 Usage
To execute the script, run the following command in the root directory of the project:
```bash
npx ts-node src/scripts/admin_interaction.ts
```

Upon running the command, the script will initiate a CLI, prompting you to select from a range of functions for execution. Follow the on-screen instructions to interact with the smart contracts.

## Available Functions
The script offers various functionalities, categorized into "view" and "write" operations:

### View Functions
- `get_admin`
- `get_flash_fee`
- `get_protocol_fee`
- `get_protocol_revenues`

### Write Functions
- `set_flash_fee`
- `set_protocol_fee`
- `claim_protocol_revenues`

## 💰Setting Protocol Fees

As an administrator, you can adjust the protocol fees charged by Tokei. Here's how to set the protocol fee using the **`set_protocol_fee`** 
- Enter the function name in this case : set_protocol_fee
- You will be prompted with the protocol fee to be set, enter the amount.
- And that's all you would have successfully set the protocol fee.

Here's an example of how you can set the protocol fee :
<img width="1373" alt="Screenshot 2024-01-25 at 9 56 17 PM" src="https://github.com/Akashneelesh/tokei/assets/66639153/43de5d3a-29cb-4297-b45b-84b546262f2a">

## Getting the Protocol Fees
Here's an example of how you can retrieve the protocol fee 
function:<img width="1374" alt="Screenshot 2024-01-25 at 9 55 08 PM" src="https://github.com/Akashneelesh/tokei/assets/66639153/13a404c4-c700-4e47-944b-d8a63e0488ab">
For each function, you will be prompted to input the necessary parameters before execution.

## **Finalizing Your Admin Tasks**

After you've set fees or claimed revenues, verify the transactions have processed successfully by checking the Starknet block explorer with the transaction hashes output by the script.

## **Conclusion**

Administering the Tokei protocol requires a careful approach to manage fees and revenues effectively. By following the steps outlined in this guide, you can confidently execute administrative tasks, ensuring Tokei continues to operate smoothly on the Starknet platform.
