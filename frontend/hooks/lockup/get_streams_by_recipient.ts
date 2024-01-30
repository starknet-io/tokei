import { Contract, RpcProvider } from "starknet"
import LockupLinear from "../../constants/abi/lockup_linear.json"

export const get_streams_by_recipient = async(accountAddress:string, contractAddress:string) => {
    try{
        const provider = new RpcProvider()
        const contract = new Contract(LockupLinear, contractAddress, provider)
        const streams_by_recipient= await contract.get_streams_by_recipient(accountAddress)
    
        return streams_by_recipient;
    }catch(e) {
        console.log("Error streams_by_recipient",e)
    }

}