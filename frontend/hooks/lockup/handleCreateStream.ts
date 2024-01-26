import { useToast } from "@chakra-ui/react";
import {
  CONTRACT_DEPLOYED_STARKNET,
  DEFAULT_NETWORK,
} from "../../constants/address";
import { CreateRangeProps } from "../../types";
import { ADDRESS_LENGTH } from "../../constants";
import {
  CallData,
  GetTransactionReceiptResponse,
  Provider,
  RpcProvider,
  cairo,
  constants,
  stark,
} from "starknet";
import { UseAccountResult } from "@starknet-react/core";

export interface IHandleCreateStream {
  form: CreateRangeProps | undefined;
  address?: string;
  accountStarknet: UseAccountResult | undefined;
  networkName?:string
}
export const handleCreateStream = async ({
  form,
  accountStarknet,
  address,
}: IHandleCreateStream): Promise<{
  tx?: GetTransactionReceiptResponse;
  isSuccess?: boolean;
  message?: string;
}> => {
  try {
    const account = accountStarknet?.account;
    const CONTRACT_ADDRESS = CONTRACT_DEPLOYED_STARKNET[DEFAULT_NETWORK];
  
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
        broker: { ...form.broker },
      }),
    });
    const provider = new Provider({
      sequencer: { network: constants.NetworkName.SN_GOERLI },
    });
    // const provider = new RpcProvider({nodeUrl:constants?.NetworkName.SN_GOERLI});
    const tx = await provider.waitForTransaction(result.transaction_hash);
    return { tx , isSuccess:true,};
  }catch(e) {
    console.log("handleCreateStream error",e)

  }
 
};


