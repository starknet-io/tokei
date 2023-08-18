# Build the contracts

Open a terminal and run the following command:

```shell
scarb build
```

This will build the smart contracts into `target` directory.

Sample output:

```shell
tree target/dev
├── za_warudo.starknet_artifacts.json
├── za_warudo_ERC20.casm.json
├── za_warudo_ERC20.sierra.json
├── za_warudo_ERC721.casm.json
├── za_warudo_ERC721.sierra.json
├── za_warudo_ZaWarudoLockupLinear.casm.json
└── za_warudo_ZaWarudoLockupLinear.sierra.json
```
