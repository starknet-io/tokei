import { Account, AccountInterface, Contract, RpcProvider } from "starknet";
import LockupLinear from "../../constants/abi/lockup_linear.json";

export const cancelStream = async (
  account:AccountInterface,
  contractAddress:string,
  stream_id:number
) => {
  try {
    const contract = new Contract(LockupLinear, contractAddress, account);
    const streams_by_sender = await contract.cancel(
      stream_id
    );

    return streams_by_sender;
  } catch (e) {
    console.log("Error cancelStream", e);
  }
};
