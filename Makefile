-include .env

deploy-sepolia:
	forge script script/NFTStaking.s.sol:NFTStakingScript --rpc-url $(SEPOLIA_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
