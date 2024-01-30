import { Account, AccountInterface, Contract, RpcProvider, Uint256 } from "starknet";
import LockupLinear from "../../constants/abi/lockup_linear.json";

export const withdrawn = async (
  account:AccountInterface,
  contractAddress:string,
  stream_id:number,
  to:string,
  amount:Uint256
) => {
  try {
    const contract = new Contract(LockupLinear, contractAddress, account);
    const streams_by_sender = await contract.withdraw(
      stream_id,
      to,
      amount

    );

    return streams_by_sender;
  } catch (e) {
    console.log("Error withdrawn", e);
  }
};

export const withdraw_max = async (
  account:AccountInterface,
  contractAddress:string,
  stream_id:number,
  to:string
) => {
  try {
    const contract = new Contract(LockupLinear, contractAddress, account);
    const streams_by_sender = await contract.withdraw_max(
      stream_id,
      to
    );

    return streams_by_sender;
  } catch (e) {
    console.log("Error withdraw_max", e);
  }
};
