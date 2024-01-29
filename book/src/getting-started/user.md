# User Interaction CLI Tool

## 🔍 Overview
This command-line interface (CLI) tool is designed for interacting with a streaming contract. It provides an easy-to-use interface to execute various functions related to asset streaming, such as creating streams, withdrawing funds, and querying stream details.

The Tokei Lockup Linear Contract is part of the Tokei protocol, designed to manage financial streams over time. This contract is particularly relevant for users interested in creating, managing, and interacting with asset streams. Key functionalities include:
Detailed Functionalities:
__________________________________________________________________________________________________________________________________________________________________
### 🏄 Stream Creation:

Users can initiate asset streams with precise timing. The contract allows specification of start, cliff, and end times, controlling the asset flow.
<br>
Durations Structure: This struct includes two key time periods - the cliff duration and the total duration. The cliff duration is a waiting period before the asset distribution starts, while the total duration is the entire span of the asset stream.
<br>
Range Structure: Defines the specific timing of the stream with start, cliff, and end timestamps. This granularity offers users flexibility in how they schedule their asset distribution.
__________________________________________________________________________________________________________________________________________________________________
## 💰Asset Management:
### Cancelable Streams:
Users have the option to cancel streams, providing flexibility and control over their asset distribution.
__________________________________________________________________________________________________________________________________________________________________

### 🚙 Transferable Rights:
Streams can be made transferable, allowing users to assign their streaming rights to others, adding an element of liquidity to their assets.
__________________________________________________________________________________________________________________________________________________________________

### 🏧 Withdrawals:
Assets can be withdrawn as per the defined schedule, offering users timely access to their funds.
__________________________________________________________________________________________________________________________________________________________________

### 🎨 Fee and NFT Integration:
The contract entails fees like protocol fees and broker fees, calculated as percentages of the total stream amount.
Each stream is uniquely represented as an NFT, providing a tangible asset that can be held, transferred, or traded.
__________________________________________________________________________________________________________________________________________________________________
### Structures in Detail:

#### Duration: 
This structure is key for defining the time frame of an asset stream. It includes two components:
#### Cliff: 
The initial period during which no assets are distributed.
#### Total: 
The entire length of the asset stream, from start to finish.
#### Range: 
This structure provides a more detailed breakdown of the stream's timeline, with specific timestamps marking the start, cliff, and end of the asset distribution.
__________________________________________________________________________________________________________________________________________________________________
## 📝 Prerequisites
Before running this tool, ensure you have the following prerequisites installed:
- Node.js
- TypeScript
- ts-node

## ⚙️ Installation
1. Clone the repository to your local machine.
2. Navigate to the project directory.
3. Install the dependencies using npm:

```bash
npm install or yarn
```

## 🔬 Usage
To start the CLI tool, run the following command in the terminal:

```bash
npx ts-node src/scripts/user_interaction.ts
```

### 🤺 Interactive CLI
Once the script is running, you will be presented with an interactive CLI. The CLI offers a range of 'view' and 'external' functions that you can call and invoke. 

### Executing Functions
Follow these steps to execute a function:
1. Choose a function from the list provided by the CLI.
2. Enter the function name when prompted.
3. You will then be prompted to provide the necessary parameters for the chosen function.
4. After entering the parameters, the function will be invoked, and the output (if any) will be displayed in the CLI.

### Available Functions
The tool provides various functions, categorized as 'view' and 'external' functions. Here's a brief overview:

#### View Functions
These functions are used to view details about streams. Examples include:
- `get_asset`
- `get_protocol_fee`
- `get_protocol_revenues`
- `get_cliff_time`
- ...and more

#### External Functions
These functions allow you to perform actions like creating or canceling streams. Examples include:
- `create_with_duration`
- `create_with_range`
- `cancel_stream`
- `withdraw_max`
- ...and more

### 🏄 Example Workflow of invoking a write function
1. Choose a function, e.g., `create_with_duration`.
2. Provide the required parameters like sender, recipient, amount, asset, etc.
3. The function will be executed, and the transaction hash or relevant information will be displayed.
An example of a transaction :
<img width="1047" alt="Screenshot 2024-01-25 at 10 13 42 PM" src="https://github.com/Akashneelesh/tokei/assets/66639153/267d1aae-e79e-4008-a20a-6292289ca9fe">

### Example Workflow of invoking a read function
1. Choose a function, e.g., `get_range`.
2. Provide the stream ID
3. The function will return back with the relevant information.
An example of a transaction :
<img width="879" alt="Screenshot 2024-01-25 at 10 15 47 PM" src="https://github.com/Akashneelesh/tokei/assets/66639153/1190b689-3edc-4a40-9d94-eaa5f9f43975">

### Example Inputs
- The example inputs are available in src/scripts/user_example.txt.
- You could refer to it for executing a test stream.

## Error Handling
If an error occurs during the execution of a function, the tool will display an error message. Please ensure that all parameters are entered correctly and in the required format.

## Closing the CLI
To exit the CLI, type `quit` at any prompt.
