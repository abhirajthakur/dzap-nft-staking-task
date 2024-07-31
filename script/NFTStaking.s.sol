// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NFTStaking} from "../src/NFTStaking.sol";

contract NFTStakingScript is Script {
    function setUp() public {}

    function run() public returns (NFTStaking) {
        NFTStaking nftStaking = new NFTStaking();

        return nftStaking;
    }
}
