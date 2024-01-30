import { useToast } from "@chakra-ui/react";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../constants/address";
import { CreateRangeProps, TxCallInterface, } from "../../types";
import { ADDRESS_LENGTH } from "../../constants";
import LockupLinearAbi from "../../constants/abi/lockup_linear.json";
// import TokeiLockupLinearAbi from "../../constants/abi/tokei_lockup.json";
import ERC20Tokei from "../../constants/abi/tokei_ERC20.contract_class.json";
import {
  Account,
  AccountInterface,
  BigNumberish,
  CallData,
  Contract,
  GetTransactionReceiptResponse,
  Provider,
  ProviderInterface,
  RpcProvider,
  Uint256,
  cairo,
  constants,
  stark,
} from "starknet";
import { UseAccountResult } from "@starknet-react/core";

const TOKEI_ADDRESS_TEST =
  CONTRACT_DEPLOYED_STARKNET[constants.NetworkName.SN_GOERLI]
    .lockupLinearFactory;
export interface IHandleCreateStream {
  form: CreateRangeProps | undefined;
  address?: string;
  accountStarknet: UseAccountResult | undefined;
  networkName?: string;
}

export interface ICreateWithDuration {
  account: Account;
  // provider:AccountInterface|ProviderInterface,
  sender: string;
  recipient: string;
  total_amount: Uint256;
  asset: string;
  cancelable: boolean;
  transferable: boolean;
  duration_cliff: number;
  duration_total: number;
  broker_account: string;
  broker_fee: Uint256;
}
export async function create_with_duration(
  account: AccountInterface,
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
): Promise<TxCallInterface>{
  try {

    console.log("sender", sender)
    console.log("recipient", recipient)
    console.log("total_amount", total_amount)
    console.log("asset", asset)
    console.log("cancelable", cancelable)
    console.log("transferable", transferable)
    console.log("duration_cliff", duration_cliff)
    console.log("duration_total", duration_total)

    console.log("broker_account", broker_account)
    console.log("broker_fee", broker_fee)

    const provider = new RpcProvider({nodeUrl:constants.NetworkName.SN_GOERLI})
    const tokeiContract = new Contract(
      LockupLinearAbi,
      TOKEI_ADDRESS_TEST,
      provider
    );
    const erc20Contract = new Contract(ERC20Tokei.abi, asset, provider);
    // Calldata for Create_with_duration
    console.log("Calldata compile")

    const calldataCreateWithDuration = CallData.compile({
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
    console.log("Execute multicall")

    // const nonce= await account.getNonce()
    // console.log("nonce",nonce)

    let success = await account.execute([
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
        calldata: calldataCreateWithDuration,
      },
    ],
    undefined,
    //  [ERC20Tokei.abi, LockupLinearAbi],
    //   {
    //   nonce:nonce
    // }
    
    );


    return {
      // tx: tx,
      hash:success?.transaction_hash,
      isSuccess: true,
      message: "200",
    };
  } catch (e) {
    console.log("Error create_with_duration", e);
    
    return {
      tx: undefined,
      isSuccess: false,
      message: e,
    };
  }
}
export const handleCreateStream = async ({
  form,
  accountStarknet,
  address,
}: IHandleCreateStream): Promise<TxCallInterface> => {
  try {
    const account = accountStarknet?.account;
    const CONTRACT_ADDRESS = CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK];

    /** @TODO go format uint256 */
    const fee = form?.broker?.fee;
    const broker = {
      account: form?.broker?.account,
      fee: fee,
    };
    const result = await account.execute({
      contractAddress: CONTRACT_ADDRESS.lockupLinearFactory?.toString(),
      entrypoint: "create_with_range",
      calldata: CallData.compile({
        sender: account?.address,
        recipient: form.recipient,
        total_amount: form?.total_amount,
        asset: form?.asset,
        cancelable: form?.cancelable,
        range: {
          ...form.range,
        },
        // broker: { ...form.broker },
        broker: { ...form.broker },
      }),
    });
    // const provider = new Provider({
    //   sequencer: { network: constants.NetworkName.SN_GOERLI },
    // });
    const provider = new RpcProvider({
      nodeUrl: constants?.NetworkName.SN_GOERLI,
    });
    const tx = await provider.waitForTransaction(result.transaction_hash);
    return { tx, isSuccess: true };
  } catch (e) {
    console.log("handleCreateStream error", e);
  }
};
