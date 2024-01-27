import {
  constants,
  Provider,
  Contract,
  Account,
  json,
  shortString,
  RpcProvider,
  hash,
  CallData,
  cairo,
  Uint256,
} from "starknet";
import fs from "fs";
import readline from "readline";
import dotenv from "dotenv";
import { utils } from "@project-serum/anchor";
dotenv.config();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function ask(question: string): Promise<string> {
  return new Promise((resolve) => rl.question(question, resolve));
}

async function main() {
  // // *************************************************************************
  // //                       TEST VALUES
  // // *************************************************************************

  // Please feel free to change the values of the variables below to test out the flow
  // The values below are just an example of how to use the functions
  // You can mint yourself some tokens from this address 0x075b1b684be1cd0f08a4a59a22994dedb6d3f5851e630b3f1a895459ef754e87
  let sender =
    "0x05D20A56d451F02B50486B7d7B2b3F25F5A594Da8AA620Ca599fd65E7312b7F4";
  let recipient =
    "0x01ad3cD865329587101B3a2c3e0B7C9ca8ac9D538F6c2179384108d8ff7E6B3d";
  let total_amount = cairo.uint256(12000000000000000000);
  let asset =
    "0x075b1b684be1cd0f08a4a59a22994dedb6d3f5851e630b3f1a895459ef754e87";
  let cancelable = true;
  let transferable = true;
  let duration_cliff = 430; // 430/60 = 7.16 minutes
  let duration_total = 700; // 700/60 = 11.66 minutes
  let broker_account =
    "0x0375b883a5A4624660EF419ed58a3c7C3ba262100CA6eE7056B65d7EB745F933";
  let broker_fee = cairo.uint256(3); // 0.03%
  let range_start = 1706132876;
  let range_cliff = 1706133071;
  let range_end = 1706139471;

  let lastTransactionHash = "";
  while (true) {
    // List of functions for the CLI
    const view_functions = [
      "get_asset",
      "get_protocol_fee",
      "get_protocol_revenues",
      "get_cliff_time",
      "get_deposited_amount",
      "get_end_time",
      "get_range",
      "get_refunded_amount",
      "get_sender",
      "get_start_time",
      "get_stream",
      "get_withdrawn_amount",
      "is_cancelable",
      "is_transferable",
      "is_depleted",
      "is_stream",
      "refundable_amount_of",
      "get_recipient",
      "is_cold",
      "is_warm",
      "withdrawable_amount_of",
      "status_of",
      "streamed_amount_of",
      "was_canceled",
      "get_streams_by_sender",
      "get_streams_by_recipient",
      "get_streams_ids_by_sender",
      "get_streams_ids_by_recipient",
    ];
    const functions = [
      "create_with_duration",
      "create_with_range",
      "cancel_stream",
      "cancel_multiple",
      "withdraw_max",
      "withdraw_multiple",
      "withdraw_max_and_transfer",
      "quit",
    ];

    console.log("\nAvailable view functions:");
    view_functions.forEach((func, index) =>
      console.log("🧪 " + `${index + 1}. ${func}`)
    );

    console.log(
      "\nAvailable Write (last transaction hash: " + lastTransactionHash + ")"
    );
    functions.forEach((func, index) =>
      console.log("🧪 " + `${index + 1}. ${func}`)
    );

    const functionName = await ask(
      "\nWhich function would you like to execute? (Enter the name): "
    );

    if (functionName.trim() === "quit") {
      console.log("Exiting program.");
      break;
    }

    switch (functionName.trim()) {
      case "create_with_duration":
        // Collect parameters for create_with_duration
        const sender = await ask("Enter sender: ");
        const recipient = await ask("Enter recipient: ");
        const total_amount = cairo.uint256(await ask("Enter total amount: "));
        const asset = await ask("Enter asset: ");
        const cancelable =
          (await ask("Is it cancelable? (true/false): ")) === "true";
        const transferable =
          (await ask("Is it transferable? (true/false): ")) === "true";
        const duration_cliff = parseInt(await ask("Enter duration cliff: "));
        const duration_total = parseInt(await ask("Enter duration total: "));
        const broker_account = await ask("Enter broker account: ");
        const broker_fee = cairo.uint256(await ask("Enter broker fee: "));
        await create_with_duration(
          sender,
          recipient,
          total_amount,
          asset,
          cancelable,
          transferable,
          duration_cliff,
          duration_total,
          broker_account,
          broker_fee
        );
        break;
      // Similar structure for other functions
      case "create_with_range":
        // Collect parameters and call create_with_range
        const sender_3 = await ask("Enter sender: ");
        const recipient_3 = await ask("Enter recipient: ");
        const total_amount_3 = cairo.uint256(await ask("Enter total amount: "));
        const asset_3 = await ask("Enter asset: ");
        const cancelable_3 =
          (await ask("Is it cancelable? (true/false): ")) === "true";
        const transferable_3 =
          (await ask("Is it transferable? (true/false): ")) === "true";
        const range_start_3 = parseInt(await ask("Enter range start: "));
        const range_cliff_3 = parseInt(await ask("Enter range cliff: "));
        const range_end_3 = parseInt(await ask("Enter range end: "));
        const broker_account_3 = await ask("Enter broker account: ");
        const broker_fee_3 = cairo.uint256(await ask("Enter broker fee: "));
        await create_with_range(
          sender_3,
          recipient_3,
          total_amount_3,
          asset_3,
          cancelable_3,
          transferable_3,
          range_start_3,
          range_cliff_3,
          range_end_3,
          broker_account_3,
          broker_fee_3
        );

        break;
      case "cancel_stream":
        // Collect parameters for cancel_stream
        const streamId = await ask("Enter stream ID: ");
        // Call the function with collected parameters
        await cancel_stream(streamId);
        break;
      case "cancel_multiple":
        // Collect parameters for cancel_multiple
        const streamIds = (await ask("Enter stream IDs (comma-separated): "))
          .split(",")
          .map((id) => parseInt(id.trim()));
        // Call the function with collected parameters
        await cancel_multiple(streamIds);
        break;
      case "withdraw_max":
        // Collect parameters for withdraw_max
        const streamIdForWithdraw = await ask("Enter stream ID: ");
        let recipientAddress = await ask("Enter recipient address: ");
        // Call the function with collected parameters
        await withdraw_max(streamIdForWithdraw, recipientAddress);
        break;
      case "withdraw_multiple":
        // Collect parameters for withdraw_multiple
        const streamIdsForWithdraw = (
          await ask("Enter stream IDs for withdrawal (comma-separated): ")
        )
          .split(",")
          .map((id) => parseInt(id.trim()));
        const amounts = (await ask("Enter amounts (comma-separated): "))
          .split(",")
          .map((amount) => parseInt(amount.trim()));
        // Call the function with collected parameters
        await withdraw_multiple(streamIdsForWithdraw, amounts);
        break;
      case "withdraw_max_and_transfer":
        // Collect parameters for withdraw_max_and_transfer
        const streamIdForMaxTransfer = await ask("Enter stream ID: ");
        const transferRecipient = await ask("Enter recipient: ");
        // Call the function with collected parameters
        await withdraw_max_and_transfer(
          streamIdForMaxTransfer,
          transferRecipient
        );
        break;
      case "get_asset":
        const streamIdForAsset = await ask("Enter stream ID: ");
        await get_asset(streamIdForAsset);
        break;
      case "get_protocol_fee":
        let stream_id = await ask("Enter stream ID: ");
        await get_protocol_fee(stream_id);
        break;
      case "get_protocol_revenues":
        let asset2 = await ask("Enter asset: ");
        await get_protocol_revenues(asset2);
        break;
      case "get_cliff_time":
        let stream_id2 = await ask("Enter stream ID: ");
        await get_cliff_time(stream_id2);
        break;
      case "get_deposited_amount":
        let stream_id3 = await ask("Enter stream ID: ");
        await get_deposited_amount(stream_id3);
        break;
      case "get_end_time":
        let stream_id4 = await ask("Enter stream ID: ");
        await get_end_time(stream_id4);
        break;
      case "get_range":
        let stream_id5 = await ask("Enter stream ID: ");
        await get_range(stream_id5);
        break;
      case "get_refunded_amount":
        let stream_id6 = await ask("Enter stream ID: ");
        await get_refunded_amount(stream_id6);
        break;
      case "get_sender":
        let stream_id7 = await ask("Enter stream ID: ");
        await get_sender(stream_id7);
        break;
      case "get_start_time":
        let stream_id8 = await ask("Enter stream ID: ");
        await get_start_time(stream_id8);
        break;
      case "get_withdrawn_amount":
        let stream_id10 = await ask("Enter stream ID: ");
        await get_withdrawn_amount(stream_id10);
        break;
      case "is_cancelable":
        let stream_id11 = await ask("Enter stream ID: ");
        await is_cancelable(stream_id11);
        break;
      case "is_transferable":
        let stream_id12 = await ask("Enter stream ID: ");
        await is_transferable(stream_id12);
        break;
      case "is_depleted":
        let stream_id13 = await ask("Enter stream ID: ");
        await is_depleted(stream_id13);
        break;
      case "is_stream":
        let stream_id14 = await ask("Enter stream ID: ");
        await is_stream(stream_id14);
        break;
      case "refundable_amount_of":
        let stream_id15 = await ask("Enter stream ID: ");
        await refundable_amount_of(stream_id15);
        break;
      case "get_recipient":
        let stream_id16 = await ask("Enter stream ID: ");
        await get_recipient(stream_id16);
        break;
      case "is_cold":
        let stream_id17 = await ask("Enter stream ID: ");
        let account2 = await ask("Enter account: ");
        await is_cold(stream_id17, account2);
        break;
      case "is_warm":
        let stream_id18 = await ask("Enter stream ID: ");
        let account3 = await ask("Enter account: ");
        await is_warm(stream_id18, account3);
        break;
      case "withdrawable_amount_of":
        let stream_id19 = await ask("Enter stream ID: ");
        let account4 = await ask("Enter account: ");
        await withdrawable_amount_of(stream_id19, account4);
        break;
      case "status_of":
        let stream_id20 = await ask("Enter stream ID: ");
        let account5 = await ask("Enter account: ");
        await status_of(stream_id20, account5);
        break;
      case "streamed_amount_of":
        let stream_id21 = await ask("Enter stream ID: ");

        await streamed_amount_of(stream_id21);
        break;
      case "was_canceled":
        let stream_id22 = await ask("Enter stream ID: ");
        await was_canceled(stream_id22);
        break;
      case "get_streams_by_sender":
        let sender2 = await ask("Enter sender: ");
        await get_streams_by_sender(sender2);
        break;
      case "get_streams_by_recipient":
        let recipient2 = await ask("Enter recipient: ");
        await get_streams_by_recipient(recipient2);
        break;
      case "get_streams_ids_by_sender":
        let sender3 = await ask("Enter sender: ");
        await get_streams_ids_by_sender(sender3);
        break;
      case "get_streams_ids_by_recipient":
        let recipient3 = await ask("Enter recipient: ");
        await get_streams_ids_by_recipient(recipient3);
        break;

      default:
        console.log("Function not recognized.");
        break;
    }
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }

  rl.close();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    rl.close();
    process.exit(1);
  });

export async function initialize_account() {
  const provider = new RpcProvider({
    nodeUrl: "SN_GOERLI",
  });

  // Check that communication with provider is OK
  const ci = await provider.getChainId();
  console.log("chain Id =", ci);

  // initialize existing Argent X testnet  account
  const adminAccountAddress =
    "0x05D20A56d451F02B50486B7d7B2b3F25F5A594Da8AA620Ca599fd65E7312b7F4";
  const adminPrivateKey =
    "0x06ab1f177bbf6b9d862412f0ec4feb0bdc520c7712f5a25c3e043cbaa29410db";

  const recipientAccountAddress =
    "0x1ad3cd865329587101b3a2c3e0b7c9ca8ac9d538f6c2179384108d8ff7e6b3d";
  const recipientPrivateKey =
    "0x05a2fe8a27eb75fb978d4ef568dbde3a0e72f0caffd30096db070d5ddba23f2a";

  const recipientAccount = new Account(
    provider,
    recipientAccountAddress,
    recipientPrivateKey
  );

  // // initialize existing Argent X mainnet  account
  // const privateKey = account4MainnetPrivateKey;
  // const accountAddress = account4MainnetAddress
  const account0 = new Account(provider, adminAccountAddress, adminPrivateKey);
  console.log("existing_ACCOUNT_ADDRESS=", adminAccountAddress);
  console.log("existing account connected.\n");

  const erc20CompiledSierra = json.parse(
    fs
      .readFileSync("target/dev/tokei_ERC20.contract_class.json")
      .toString("ascii")
  );
  const erc20CompiledCasm = json.parse(
    fs
      .readFileSync("target/dev/tokei_ERC20.compiled_contract_class.json")
      .toString("ascii")
  );

  const tokeiCompiledSierra = json.parse(
    fs
      .readFileSync("target/dev/tokei_TokeiLockupLinear.contract_class.json")
      .toString("ascii")
  );
  const compiledCasm = json.parse(
    fs
      .readFileSync(
        "target/dev/tokei_TokeiLockupLinear.compiled_contract_class.json"
      )
      .toString("ascii")
  );

  const erc20ClassHash =
    "0x01645152801d7bef56b3bdc02e0f13bbfb5646f3b3bda875f633df8f9b58b35d";
  const erc20address =
    "0x075b1b684be1cd0f08a4a59a22994dedb6d3f5851e630b3f1a895459ef754e87";

  const tokeiClassHash =
    "0x0642757913747e242c09cbbe73a3ab5733dfde42bc9293ed1b3642202dde7ff8";
  const tokeiaddress =
    "0x682799e0ba490a32a4e24cf8a349b8d3560ee48f7ef2b9349b5cb4a527e99ae";

  // console.log("✅ ERC20 Contract declared with classHash =", erc20ClassHash);
  // console.log("✅ Tokei Contract declared with classHash =", tokeiClassHash);

  // *************************************************************************
  //                      CONTRACT CONNECTION
  // *************************************************************************

  const tokeiContract = new Contract(
    tokeiCompiledSierra.abi,
    tokeiaddress,
    provider
  );
  // console.log("✅ Tokei Contract connected at =", tokeiContract.address);
  tokeiContract.connect(account0);

  const erc20Contract = new Contract(
    erc20CompiledSierra.abi,
    erc20address,
    provider
  );
  // console.log("✅ ERC20 Contract connected at =", erc20Contract.address);
  erc20Contract.connect(account0);

  console.log(" 🤔 In process ...");

  return { account0, recipientAccount, tokeiContract, erc20Contract, provider };
}

export async function cancel_stream(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par6 = CallData.compile({
    stream_id: stream_id,
  });

  let success6 = await account0.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "cancel",
      calldata: par6,
    },
  ]);

  console.log("✅ cancel_stream invoked at :", success6.transaction_hash);
}

async function withdraw_max(stream_id: string, recipientAddress: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par3 = CallData.compile({
    stream_id: stream_id,
    to: recipientAddress,
  });

  let success3 = await recipientAccount.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "withdraw_max",
      calldata: par3,
    },
  ]);

  console.log("✅ withdraw_max invoked at :", success3.transaction_hash);
}

async function withdraw_multiple(stream_ids: number[], amounts: number[]) {
  let amounts_mod = amounts.map((amount) => cairo.uint256(amount));

  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par4 = CallData.compile({
    stream_ids: stream_ids,
    to: recipientAccount.address,
    amounts: amounts_mod,
  });

  let success4 = await account0.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "withdraw_multiple",
      calldata: par4,
    },
  ]);

  console.log("✅ withdraw_multiple invoked at :", success4.transaction_hash);
}

async function withdraw_max_and_transfer(stream_id: string, to: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par5 = CallData.compile({
    stream_id: stream_id,
    to: to,
  });

  let success5 = await recipientAccount.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "withdraw_max_and_transfer",
      calldata: par5,
    },
  ]);

  console.log(
    "✅ withdraw_max_and_transfer invoked at :",
    success5.transaction_hash
  );
}

async function create_with_duration(
  sender: string,
  recipient: string,
  total_amount: Uint256,
  asset: string,
  cancelable: boolean,
  transferable: boolean,
  duration_cliff: number,
  duration_total: number,
  broker_account: string,
  broker_fee: Uint256
) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  // Calldata for Create_with_duration
  const par1 = CallData.compile({
    sender: sender,
    recipient: recipient,
    total_amount: total_amount,
    asset: asset,
    cancelable: cancelable,
    transferable: transferable,
    duration_cliff: duration_cliff,
    duration_total: duration_total,
    broker_account: broker_account,
    broker_fee: broker_fee,
  });

  // // *************************************************************************************
  // //                       TOKEN APPROVAL TO THE TOKEI CONTRACT & CREATE_WITH_DURATION
  // // ****************************************************************************************
  // // Multicall transaction with approval and create_with_duration
  let success = await account0.execute([
    {
      contractAddress: erc20Contract.address,
      entrypoint: "approve",
      calldata: CallData.compile({
        recipient: tokeiContract.address,
        amount: total_amount,
      }),
    },
    {
      contractAddress: tokeiContract.address,
      entrypoint: "create_with_duration",
      calldata: par1,
    },
  ]);
  console.log("✅ create_with_duration invoked at :", success.transaction_hash);
}

async function create_with_range(
  sender: string,
  recipient: string,
  total_amount: Uint256,
  asset: string,
  cancelable: boolean,
  transferable: boolean,
  range_start: number,
  range_cliff: number,
  range_end: number,
  broker_account: string,
  broker_fee: Uint256
) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  // Calldata for Create_with_range

  let par2 = CallData.compile({
    sender: sender,
    recipient: recipient,
    total_amount: total_amount,
    asset: asset,
    cancelable: cancelable,
    transferable: transferable,
    range_start: range_start,
    range_cliff: range_cliff,
    range_end: range_end,
    broker_account: broker_account,
    broker_fee: broker_fee,
  });

  // Multicall transaction with approval and create_with_range
  let success2 = await account0.execute([
    {
      contractAddress: erc20Contract.address,
      entrypoint: "approve",
      calldata: CallData.compile({
        recipient: tokeiContract.address,
        amount: total_amount,
      }),
    },
    {
      contractAddress: tokeiContract.address,
      entrypoint: "create_with_range",
      calldata: par2,
    },
  ]);

  console.log("✅ create_with_range invoked at :", success2.transaction_hash);
}

async function cancel_multiple(stream_ids: number[]) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  // Calldata for Cancel_multiple
  let par7 = CallData.compile({
    stream_ids: stream_ids,
  });

  let success7 = await account0.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "cancel_multiple",
      calldata: par7,
    },
  ]);

  console.log("✅ cancel_multiple invoked at :", success7.transaction_hash);
}

async function get_asset(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await tokeiContract.call(
    "get_asset",
    CallData.compile({
      stream_id: stream_id,
    })
  );

  console.log("✅ asset =", success.toString());
}

async function get_protocol_fee(asset: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await tokeiContract.call(
    "get_protocol_fee",
    CallData.compile({ asset: asset })
  );

  console.log("✅ protocol fee =", success.toString());
}

async function get_protocol_revenues(asset: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await tokeiContract.call(
    "get_protocol_revenues",
    CallData.compile({ asset: asset })
  );

  console.log("✅ protocol revenues for the given asset :", success.toString());
}

async function get_cliff_time(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par1 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_cliff_time", par1);

  console.log("✅ cliff time =", success.toString());
}

async function get_deposited_amount(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par2 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_deposited_amount", par2);

  console.log("✅ deposited amount =", success.toString());
}

async function get_end_time(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par3 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_end_time", par3);

  console.log("✅ end time =", success.toString());
}

async function get_range(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par4 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_range", par4);

  console.log("✅ range =", success.valueOf());
}

async function get_refunded_amount(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par5 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_refunded_amount", par5);

  console.log("✅ refunded amount =", success.toString());
}

async function get_sender(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par6 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_sender", par6);

  console.log("✅ sender =", success.toString());
}

async function get_start_time(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par7 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_start_time", par7);

  console.log("✅ start time =", success.toString());
}

async function get_streams_by_sender(sender: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par8 = CallData.compile({
    sender: sender,
  });

  let success = await tokeiContract.call("get_streams_by_sender", par8);

  console.log("✅ streams =", success.valueOf());
}

async function get_streams_by_recipient(recipient: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par9 = CallData.compile({
    recipient: recipient,
  });

  let success = await tokeiContract.call("get_streams_by_recipient", par9);

  console.log("✅ streams =", success.valueOf());
}

async function get_streams_ids_by_sender(sender: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par10 = CallData.compile({
    sender: sender,
  });

  let success = await tokeiContract.call("get_streams_ids_by_sender", par10);

  console.log("✅ streams =", success.toString());
}

async function get_streams_ids_by_recipient(recipient: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par11 = CallData.compile({
    recipient: recipient,
  });

  let success = await tokeiContract.call("get_streams_ids_by_recipient", par11);

  console.log("✅ streams =", success.toString());
}

async function get_withdrawn_amount(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par9 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_withdrawn_amount", par9);

  console.log("✅ withdrawn amount =", success.toString());
}

async function is_cancelable(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par10 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("is_cancelable", par10);

  console.log("✅ cancelable =", success.toString());
}

async function is_transferable(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par11 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("is_transferable", par11);

  console.log("✅ transferable =", success.toString());
}

async function is_depleted(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par12 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("is_depleted", par12);

  console.log("✅ depleted =", success.toString());
}

async function is_stream(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par13 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("is_stream", par13);

  console.log("✅ stream =", success.toString());
}

async function refundable_amount_of(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par14 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("refundable_amount_of", par14);

  console.log("✅ refundable amount =", success.toString());
}

async function get_recipient(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par15 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("get_recipient", par15);

  console.log("✅ recipient =", success.toString());
}

async function is_cold(stream_id: string, account: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par16 = CallData.compile({
    stream_id: stream_id,
    account: account,
  });

  let success = await tokeiContract.call("is_cold", par16);

  console.log("✅ cold =", success.toString());
}

async function is_warm(stream_id: string, account: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par17 = CallData.compile({
    stream_id: stream_id,
    account: account,
  });

  let success = await tokeiContract.call("is_warm", par17);

  console.log("✅ warm =", success.toString());
}

async function withdrawable_amount_of(stream_id: string, account: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par18 = CallData.compile({
    stream_id: stream_id,
    account: account,
  });

  let success = await tokeiContract.call("withdrawable_amount_of", par18);

  console.log("✅ withdrawable amount =", success.toString());
}

async function status_of(stream_id: string, account: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par19 = CallData.compile({
    stream_id: stream_id,
    account: account,
  });

  let success = await tokeiContract.call("status_of", par19);

  console.log("✅ status =", success.toString());
}

async function streamed_amount_of(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par20 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("streamed_amount_of", par20);

  console.log("✅ streamed amount =", success.toString());
}

async function was_canceled(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let par21 = CallData.compile({
    stream_id: stream_id,
  });

  let success = await tokeiContract.call("was_canceled", par21);

  console.log("✅ canceled =", success.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
