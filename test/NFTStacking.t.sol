// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {NFTStaking} from "../src/NFTStaking.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {MockERC721} from "../src/MockERC721.sol";

contract NFTStakingTest is Test {
    NFTStaking public nftStaking;
    MockERC20 public rewardToken;
    MockERC721 public nftToken;

    function setUp() public {
        rewardToken = new MockERC20("Reward Token", "RTK");
        nftToken = new MockERC721("NFT Token", "NFT");
        nftStaking = new NFTStaking();

        nftStaking.initialize(
            address(nftToken),
            address(rewardToken),
            1 ether, // Reward per block
            10, // Unbonding period
            5 // Claim delay
        );

        vm.broadcast();
    }

    function testStakeAndUnstake() public {
        uint256 tokenId = 1;
        nftToken.mint(address(this));

        uint256[] memory tokens = new uint256[](1);
        tokens[0] = tokenId;

        nftToken.approve(address(nftStaking), tokenId);
        nftStaking.stake(tokens);

        assertTrue(nftStaking.isStaked(address(this), tokenId));
        assertEq(nftToken.ownerOf(tokenId), address(nftStaking));

        nftStaking.unstake(tokenId);

        assertFalse(nftStaking.isStaked(address(this), tokenId));
    }

    function testClaimRewards() public {
        uint256 tokenId = 2;
        nftToken.mint(address(this));
        nftToken.approve(address(nftStaking), tokenId);

        uint256[] memory tokens = new uint256[](1);
        tokens[0] = tokenId;

        nftStaking.stake(tokens);

        vm.roll(block.number + 10); // Simulate blocks passed

        uint256 rewardsBefore = rewardToken.balanceOf(address(this));
        nftStaking.claimRewards();
        uint256 rewardsAfter = rewardToken.balanceOf(address(this));

        assertEq(rewardsAfter - rewardsBefore, 10 ether); // Assuming 1 ether reward per block
    }

    function testPauseUnpause() public {
        assertTrue(!nftStaking.paused());

        nftStaking.pause();

        assertTrue(nftStaking.paused());

        nftStaking.unpause();

        assertTrue(!nftStaking.paused());
    }
}
