import { constants } from "starknet";


export const DEFAULT_NETWORK= constants.NetworkName.SN_GOERLI
interface ContractAddressByChain {
  ethAddress?:string;
  erc721Factory?: string;
  erc20Factory?: string;
  lockupLinearFactory?:string;
}

interface ChainAddressesName {
  [chainId: string | number]: ContractAddressByChain;
}

export const CONTRACT_DEPLOYED_STARKNET: ChainAddressesName = {
  1: {},
  [constants.NetworkName.SN_GOERLI]: {
    ethAddress:"0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7",
    lockupLinearFactory:"0x0682799e0ba490a32a4e24cf8a349b8d3560ee48f7ef2b9349b5cb4a527e99ae"

  },
  [constants.NetworkName.SN_MAIN]: {


  },

};

interface ChainAddressesTips {
  [chainId: string | number]: TokenTips[];
}

interface TokenTips {
  title?: string;
  image?: string;
  address?: string;
  value?: string;
}

export const TOKEN_TIPS: ChainAddressesTips = {

};
