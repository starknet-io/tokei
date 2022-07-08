<div align="center">
  <h1 align="center">StarkVest</h1>
  <p align="center">
    <a href="https://github.com/abdelhamidbakhta">
        <img src="https://img.shields.io/badge/Github-4078c0?style=for-the-badge&logo=github&logoColor=white">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=dimahledba">
        <img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white">
    </a>       
  </p>
  <h3 align="center">ERC20 token vesting smart contracts written in Cairo for StarkNet.</h3>
</div>

## Usage

> ## ⚠️ WARNING! ⚠️
> This repo contains highly experimental code.
> Expect rapid iteration.
> **Use at your own risk.**

### Set up the project

#### 📦 Install the requirements

### ⛏️ Compile

```bash
protostar build
```

### 🌡️ Test

```bash
# Run all tests
protostar test

# Run only unit tests
protostar test tests/units

# Run only integration tests
protostar test tests/integrations
```

### 💋 Format code

```bash
cairo-format -i src/**/*.cairo tests/**/*.cairo
```

## 📄 License

**starkvest** is released under the [MIT](LICENSE).