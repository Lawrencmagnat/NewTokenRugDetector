Perfect — here’s a polished, **GitHub-ready** `README.md` version with clean formatting, emojis, badges, and proper Markdown layout. It’s professional yet engaging, like something you’d proudly showcase on your profile.

---

```markdown
# 🕵️‍♂️ NewToken Rug Detector  

---

## 🧩 Overview  

**NewToken Rug Detector** is a **Drosera-compatible smart contract** that helps detect potential rug pulls for newly launched tokens on UniswapV2-style DEX pairs.  

It works by monitoring the liquidity of a specific pair and flags any large, suspicious liquidity drops that occur within a short time window — an early warning system for “new-token rugs.”

This repository also includes a **ResponseProtocol deployment script** and a **Drosera configuration (.toml)** for easy integration and automation.

---

## 📁 Project Structure  

```

├── src/
│   └── NewTokenRugDetector.sol         # Main Rug Detector contract
├── script/
│   └── DeployResponseProtocol.s.sol    # Script to deploy ResponseProtocol
├── config/
│   └── drosera.toml                    # Drosera integration config
└── README.md

```

---

## ⚙️ Smart Contracts  

### 💣 NewTokenRugDetector.sol  

#### 🧠 Purpose  
Detect early-stage rug pulls by analyzing the liquidity behavior of a UniswapV2-compatible pair.  

It identifies a rug when liquidity drops sharply (≥ 50% by default) within a short time window (≤ 500 blocks).  

---

### 🔑 Key Constants  

| Variable | Description |
|-----------|-------------|
| `PAIR` | Address of the UniswapV2-style liquidity pair being monitored |
| `THRESHOLD_BPS` | Liquidity drop threshold in basis points (default: 5000 = 50%) |
| `LAUNCH_WINDOW_BLOCKS` | Max block window where a large drop is considered a rug (default: 500) |

---

### ⚡ Main Functions  

#### `collect()`  
Safely fetches the total liquidity and current block number from the Uniswap pair.  
Returns encoded `(totalLiquidity, blockNumber)` values.  
If the pair doesn’t exist or has no code, it safely returns zero liquidity.  

#### `shouldRespond()`  
Analyzes multiple data points to detect large liquidity drops within the defined block range.  
If the drop meets or exceeds the threshold, the function triggers a response flag.  

**Trigger condition:**  
```

Liquidity drop ≥ THRESHOLD_BPS
AND
(latestBlock - oldestBlock) ≤ LAUNCH_WINDOW_BLOCKS

````

---

## 🚀 DeployResponseProtocol Script  

The `DeployResponseProtocol.s.sol` script deploys the **ResponseProtocol** contract to your target network using Foundry.

```solidity
contract DeployResponseProtocol is Script, Test {
    function run() external {
        vm.startBroadcast();
        ResponseProtocol _responseProtocol = new ResponseProtocol();
        vm.stopBroadcast();
    }
}
````

### ▶️ Deployment Command

```bash
forge script script/DeployResponseProtocol.s.sol \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

---

## 🧭 Drosera Integration

The provided **drosera.toml** file allows seamless integration with the Drosera relay system.

### Example Configuration

```toml
ethereum_rpc = "https://ethereum-hoodi-rpc.publicnode.com/"
drosera_rpc = "https://relay.hoodi.drosera.io/"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]

[traps.new_token_rug_detector]
path = "out/NewTokenRugDetector.sol/NewTokenRugDetector.json"
response_contract = "0x0000000000000000000000000000000000000000"
response_function = ""
cooldown_period_blocks = 50
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 8
private_trap = true
whitelist = ["0xF5b50349E7Dc2be6d8E5ae7293CBE1DB63589cD9"]
```

### Key Fields

| Field                    | Description                                     |
| ------------------------ | ----------------------------------------------- |
| `path`                   | Compiled contract ABI/bytecode path             |
| `response_contract`      | Address of the response protocol contract       |
| `cooldown_period_blocks` | Blocks to wait between responses                |
| `block_sample_size`      | Number of collected data points analyzed        |
| `private_trap`           | Enables private monitoring mode                 |
| `whitelist`              | Addresses allowed to access or trigger the trap |

---

## 🛠 Setup & Deployment Guide

### 1️⃣ Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2️⃣ Clone the Repository

```bash
git clone https://github.com/<yourusername>/newtoken-rug-detector.git
cd newtoken-rug-detector
```

### 3️⃣ Build Contracts

```bash
forge build
```

### 4️⃣ Deploy ResponseProtocol

```bash
forge script script/DeployResponseProtocol.s.sol \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

### 5️⃣ Deploy Rug Detector

Deploy `NewTokenRugDetector.sol` either via Foundry or Remix,
then update the deployed contract address in your `drosera.toml` file.

### 6️⃣ Connect to Drosera

Start the Drosera relay or CLI and watch for rug detection responses.


## 🧠 How It Works

1. **Drosera Relay** periodically calls `collect()` on the trap contract.
2. The liquidity and block data are stored as samples.
3. `shouldRespond()` compares recent samples for liquidity drops.
4. If the drop exceeds the set threshold, Drosera triggers a response action (alert/report).
5. This system enables decentralized, on-chain rug pull detection for new tokens.


## 🧰 Technologies

* **Solidity (v0.8.20)**
* **Foundry** — for scripting, testing, and deployment
* **Drosera Protocol** — decentralized trap monitoring
* **UniswapV2 Interface** — for liquidity data access

## 📜 License

This project is licensed under the **MIT License**.
You’re free to use, modify, and distribute it under the same terms.


## 💡 Author

**Sir Casper (Casperdtester)**
Blockchain Expert | DeFi Researcher | Smart Contract Developer

🔗 [Twitter/X](https://x.com/ChukwuLawrencem)  | 🌐 [GitHub](https://github.com/Lawrencmagnat)


> **Note:** Update the `PAIR` constant in `NewTokenRugDetector.sol` before deploying,
> using the actual Uniswap pair address you want to monitor.

<img width="1354" height="633" alt="image" src="https://github.com/user-attachments/assets/76e236de-5c80-4397-a6e2-b56db1dd11cb" />
