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

async function main() {
  // // *************************************************************************
  // //                       FUNCTION PARAMETER VARIABLES INITIALIZATION
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
  let duration_cliff = 430;
  let duration_total = 700;
  let broker_account =
    "0x0375b883a5A4624660EF419ed58a3c7C3ba262100CA6eE7056B65d7EB745F933";
  let broker_fee = cairo.uint256(3); // 0.03%
  let range_start = 1706127871;
  let range_cliff = 1706128171;
  let range_end = 1706128371;

  // *************************************************************************
  //                  Create_with_duration
  // *************************************************************************
  // await create_with_duration(
  //   sender,
  //   recipient,
  //   total_amount,
  //   asset,
  //   cancelable,
  //   transferable,
  //   duration_cliff,
  //   duration_total,
  //   broker_account,
  //   broker_fee
  // );

  // *************************************************************************
  //                  Create_with_range
  // *************************************************************************

  // await create_with_range(
  //   sender,
  //   recipient,
  //   total_amount,
  //   asset,
  //   cancelable,
  //   transferable,
  //   0,
  //   0,
  //   0,
  //   broker_account,
  //   broker_fee
  // );

  // *************************************************************************
  //                 Cancel stream
  // *************************************************************************

  // await cancel_stream("8");

  // *************************************************************************
  //                 Cancel Multiple stream
  // *************************************************************************

  // await cancel_multiple([7, 8]);

  // *************************************************************************
  //                 Withdraw max
  // *************************************************************************

  // await withdraw_max("9");

  // *************************************************************************
  //                  Withdraw multiple
  // *************************************************************************

  // await withdraw_multiple([7, 9], [9000000000000000000, 8000000000000000000]);

  // *************************************************************************
  //                 Withdraw max and transfer
  // *************************************************************************

  // await withdraw_max_and_transfer("9", recipient);
}

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
    "0x00890b38f484174605c68c956b2b5263950610e5da509fb35807afb321a3a10d";
  const tokeiaddress =
    "0x0661bd47eb4c872cd316a305dc673221a8f8a27379e6aa3a97a21a542efbb76f";

  console.log("✅ Tokei Contract declared with classHash =", erc20ClassHash);
  console.log("✅ Tokei Contract declared with classHash =", tokeiClassHash);

  // *************************************************************************
  //                      CONTRACT CONNECTION
  // *************************************************************************

  const tokeiContract = new Contract(
    tokeiCompiledSierra.abi,
    tokeiaddress,
    provider
  );
  console.log("✅ Tokei Contract connected at =", tokeiContract.address);
  tokeiContract.connect(account0);

  const erc20Contract = new Contract(
    erc20CompiledSierra.abi,
    erc20address,
    provider
  );
  console.log("✅ ERC20 Contract connected at =", erc20Contract.address);
  erc20Contract.connect(account0);

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

async function withdraw_max(stream_id: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;
  let par3 = CallData.compile({
    stream_id: stream_id,
    to: recipientAccount.address,
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

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
