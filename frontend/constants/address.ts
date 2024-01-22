
interface ContractAddressByChain {
  erc721Factory?: string;
  erc20Factory?: string;
  mintErc721Factory?: string;
  mintErc20Factory?: string;
}

interface ChainAddresses {
  [chainId: string | number]: ContractAddressByChain;
}

export const CONTRACT_DEPLOYED: ChainAddresses = {
  1: {},

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
