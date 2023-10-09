# Build the contracts

Open a terminal and run the following command:

```shell
scarb build
```

This will build the smart contracts into `target` directory.

Sample output:

```shell
tree target/dev
├── tokei.starknet_artifacts.json
├── tokei_ERC20.casm.json
├── tokei_ERC20.sierra.json
├── tokei_ERC721.casm.json
├── tokei_ERC721.sierra.json
├── tokei_TokeiLockupLinear.casm.json
└── tokei_TokeiLockupLinear.sierra.json
```
