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
├── tokei_ERC20.compiled_contract_class.json
├── tokei_ERC20.contract_class.json
├── tokei_TokeiLockupLinear.compiled_contract_class.json
└── tokei_TokeiLockupLinear.contract_class.json
```
