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
import { ethers } from "ethers";

// import { account5TestnetAddress, account5TestnetPrivateKey } from "../../../A1priv/A1priv";

async function main() {
  // *************************************************************************
  //                       To set the protocol fee
  // *************************************************************************

  await set_protocol_fee(1); //0.01%  - Uncomment when you are using this function and comment out when you are not using it

  // *************************************************************************
  //                       To claim the protocol revenues
  // *************************************************************************

  //   await claim_protocol_revenues(); // Uncomment when you are using this function and comment out when you are not using it

  // *************************************************************************
  //                       To get the protocol fee
  // *************************************************************************

  //   await get_protocol_fee(); // Uncomment when you are using this function and comment out when you are not using it

  // *************************************************************************
  //                       To get the protocol revenues
  // *************************************************************************

  //   await get_protocol_revenues(); // Uncomment when you are using this function and comment out when you are not using it
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
async function get_protocol_fee() {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success = await tokeiContract.call(
    "get_protocol_fee",
    CallData.compile({ asset: erc20Contract.address })
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
async function claim_protocol_revenues() {
  const info = await initialize_account();
  const { account0, recipientAccount, tokeiContract, erc20Contract, provider } =
    info;

  let success2 = await account0.execute([
    {
      contractAddress: tokeiContract.address,
      entrypoint: "claim_protocol_revenues",
      calldata: CallData.compile({
        asset: erc20Contract.address,
      }),
    },
  ]);

  console.log(
    "✅ protocol fee has been claimed -> Transaction Hash :",
    success2.transaction_hash
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
