import { Contract, RpcProvider } from "starknet";
import LockupLinear from "../../constants/abi/lockup_linear.json";

export const get_streams_by_sender = async (
  accountAddress: string,
  contractAddress: string
) => {
  try {
    const provider = new RpcProvider();
    const contract = new Contract(LockupLinear, contractAddress, provider);
    const streams_by_sender = await contract.get_streams_by_sender(
      accountAddress
    );

    return streams_by_sender;
  } catch (e) {
    console.log("Error get_streams_by_sender", e);
  }
};
