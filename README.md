    # Submission for DZap NFT Staking Task

## Local Development

> **Important**:
> You need to have foundry installed.

### 1. Clone the Repository

```bash
git clone https://github.com/abhirajthakur/dzap-nft-staking-task
```

### 2. Navigate to the project directory:

```bash
cd dzap-nft-staking-app
```

### 3. Create a .env file based on the .env.example file and configure the given content

```bash
PRIVATE_KEY=
SEPOLIA_RPC_URL=
ETHERSCAN_API_KEY=
```

### 4. Install dependencies:

```bash
forge install

```

You can deploy the code by running the following command:

```bash
forge script script/NFTStaking.s.sol:NFTStakingScript --rpc-url "YOUR_SEPOLIA_RPC_URL" --broadcast --private-key "YOUR_PRIVATE_KEY" --verify --etherscan-api-key "YOUR_ETHERSCAN_API_KEY"
```

I've also created a Makefile for easily running this command.
You can just run in your terminal:

```bash
 make deploy-seplolia
```
