// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract NFTStaking is
    Initializable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    // Struct to hold information about each staked NFT
    struct StakedNFT {
        uint256 tokenId;
        uint256 stakedAt;
        bool isStaked;
    }

    // Mapping from user address to their staked NFTs
    mapping(address user => StakedNFT[]) public stakedNFTs;

    // ERC20 token for rewards
    IERC20 public rewardToken;

    // ERC721 token for NFTs
    IERC721 public nftToken;

    // Reward per block
    uint256 public rewardPerBlock;

    // Unbonding period
    uint256 public unbondingPeriod;

    // Delay period for claiming rewards
    uint256 public claimDelay;

    // Pause status
    bool public paused;

    // Events
    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardPerBlockUpdated(uint256 newRewardPerBlock);
    event Paused();
    event Unpaused();

    // Modifier to check if the contract is paused
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() {
        _disableInitializers();
    }

    // Initialize the contract
    function initialize(
        address _nftToken,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _unbondingPeriod,
        uint256 _claimDelay
    ) public initializer {
        __ERC20_init("DZap token", "DZap");
        __ERC20Permit_init("DZap token");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        nftToken = IERC721(_nftToken);
        rewardToken = IERC20(_rewardToken);
        rewardPerBlock = _rewardPerBlock;
        unbondingPeriod = _unbondingPeriod;
        claimDelay = _claimDelay;
        paused = false;
    }

    // Stake NFTs
    function stake(uint256[] calldata tokenIds) external whenNotPaused {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            nftToken.transferFrom(msg.sender, address(this), tokenIds[i]);
            stakedNFTs[msg.sender].push(
                StakedNFT({
                    tokenId: tokenIds[i],
                    stakedAt: block.number,
                    isStaked: true
                })
            );
            emit Staked(msg.sender, tokenIds[i]);
        }
    }

    // Unstake NFTs
    function unstake(uint256 tokenId) external whenNotPaused {
        require(isStaked(msg.sender, tokenId), "NFT not staked");

        // Mark NFT as unstaked
        for (uint256 i = 0; i < stakedNFTs[msg.sender].length; i++) {
            if (stakedNFTs[msg.sender][i].tokenId == tokenId) {
                stakedNFTs[msg.sender][i].isStaked = false;
                break;
            }
        }

        emit Unstaked(msg.sender, tokenId);
    }

    // Withdraw NFTs after unbonding period
    function withdraw(uint256 tokenId) external {
        require(!isStaked(msg.sender, tokenId), "NFT is still staked");

        // Check if unbonding period has passed
        require(
            block.number >=
                stakedNFTs[msg.sender][tokenId].stakedAt + unbondingPeriod,
            "Unbonding period not over"
        );

        nftToken.transferFrom(address(this), msg.sender, tokenId);
    }

    // Claim rewards
    function claimRewards() external {
        uint256 rewards = calculateRewards(msg.sender);
        require(rewards > 0, "No rewards to claim");

        rewardToken.transfer(msg.sender, rewards);
        emit RewardsClaimed(msg.sender, rewards);
    }

    // Calculate rewards for a user
    function calculateRewards(address user) internal view returns (uint256) {
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < stakedNFTs[user].length; i++) {
            if (stakedNFTs[user][i].isStaked) {
                totalRewards +=
                    (block.number - stakedNFTs[user][i].stakedAt) *
                    rewardPerBlock;
            }
        }
        return totalRewards;
    }

    // Pause staking
    function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }

    // Unpause staking
    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused();
    }

    // Update reward per block
    function updateRewardPerBlock(
        uint256 newRewardPerBlock
    ) external onlyOwner {
        rewardPerBlock = newRewardPerBlock;
        emit RewardPerBlockUpdated(newRewardPerBlock);
    }

    // Check if an NFT is staked
    function isStaked(
        address user,
        uint256 tokenId
    ) public view returns (bool) {
        for (uint256 i = 0; i < stakedNFTs[user].length; i++) {
            if (stakedNFTs[user][i].tokenId == tokenId) {
                return stakedNFTs[user][i].isStaked;
            }
        }
        return false;
    }

    // UUPS upgradeable function
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
