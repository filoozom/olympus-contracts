// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Chest } from 'src/Chests.sol';

library ChestsData {
	function getChests() public pure returns (Chest[] memory chests) {
		chests = new Chest[](4);
		chests[0] = Chest(0, 1000, 40e18);
		chests[1] = Chest(0, 500, 80e18);
		chests[2] = Chest(0, 250, 160e18);
		chests[3] = Chest(0, 140, 300e18);
	}
}
