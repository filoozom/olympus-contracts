// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Solmate
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { Marketplace } from 'src/Marketplace.sol';

contract RandomnessTest is Test {
	Marketplace marketplace;

	function setUp() public {
		marketplace = new Marketplace(address(this), Authority(address(0)));
	}

	function testERC721Listing(uint256) public {}
}
