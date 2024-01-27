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
import { ethers } from "ethers";

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function ask(question: string): Promise<string> {
  return new Promise((resolve) => rl.question(question, resolve));
}

async function main() {
  let lastTransactionHash = "";
  while (true) {
    // List of functions for the CLI
    const view_functions = [
      "get_admin",
      "get_flash_fee",
      "get_protocol_fee",
      "get_protocol_revenues",
    ];
    const functions = [
      "set_flash_fee",
      "set_protocol_fee",
      "claim_protocol_revenues",
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
      case "get_protocol_fee":
        // Collect parameters for create_with_duration
        let token_ = await ask("Enter the asset address: ");
        // Call the function with collected parameters
        await get_protocol_fee(token_);
        break;
      // Similar structure for other functions
      case "get_flash_fee":
        // Collect parameters and call create_with_range
        await get_flash_fee();
        break;
      case "get_admin":
        // Call the function with collected parameters
        await get_admin();
        break;
      case "claim_protocol_revenues":
        // Collect parameters for cancel_multiple
        const asset = await ask("Enter the asset : ");

        // Call the function with collected parameters
        await claim_protocol_revenues(asset);
        break;
      case "set_flash_fee":
        // Collect parameters for withdraw_multiple

        const flash_fee = parseInt(await ask("Enter the new flash fee: "));
        // Call the function with collected parameters
        await set_flash_fee(flash_fee);
        break;
      case "set_protocol_fee":
        const protocol_fee = parseInt(
          await ask("Enter the new protocol fee: ")
        );
        await set_protocol_fee(protocol_fee);
        break;
      case "get_protocol_revenues":
        // Collect parameters and call create_with_range
        await get_protocol_revenues();
        break;

      default:
        console.log("Function not recognized.");
        break;
    }
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }

  rl.close();
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
    "0x0642757913747e242c09cbbe73a3ab5733dfde42bc9293ed1b3642202dde7ff8";
  const tokeiaddress =
    "0x682799e0ba490a32a4e24cf8a349b8d3560ee48f7ef2b9349b5cb4a527e99ae";

  console.log("✅ ERC20 Contract declared with classHash =", erc20ClassHash);
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
async function get_protocol_fee(asset: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await tokeiContract.call(
    "get_protocol_fee",
    CallData.compile({ asset: asset })
  );

  console.log("protocol fee =", success.toString());
}

async function get_protocol_revenues() {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await tokeiContract.call(
    "get_protocol_revenues",
    CallData.compile({ asset: erc20Contract.address })
  );

  console.log("✅ protocol revenues for the given asset :", success.toString());
}

async function set_protocol_fee(protocol_fee: number) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await account0.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "set_protocol_fee",
      calldata: CallData.compile({
        asset: erc20Contract.address,
        amount: cairo.uint256(protocol_fee),
      }),
    },
  ]);

  console.log(
    "✅ protocol fee has been set  -> Transaction Hash :",
    success.transaction_hash
  );
}

async function set_flash_fee(flash_fee: number) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await account0.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "set_flash_fee",
      calldata: CallData.compile({
        amount: cairo.uint256(flash_fee),
      }),
    },
  ]);

  console.log(
    "✅ flash fee has been set  -> Transaction Hash :",
    success.transaction_hash
  );
}

async function get_flash_fee() {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await tokeiContract.call("get_flash_fee");

  console.log("✅ flash fee =", success.toString());
}
async function claim_protocol_revenues(asset: string) {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success2 = await account0.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "claim_protocol_revenues",
      calldata: CallData.compile({
        asset: asset,
      }),
    },
  ]);

  console.log(
    "✅ protocol fee has been claimed -> Transaction Hash :",
    success2.transaction_hash
  );
}

async function get_admin() {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success2 = await tokeiContract.call("get_admin");
  let res = success2.valueOf();

  console.log("✅ The protocol admin is -> :", "0x" + res.toString(16));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
