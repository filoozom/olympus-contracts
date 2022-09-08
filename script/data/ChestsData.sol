// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Custom
import { Chest } from 'src/Chests.sol';

library ChestsData {
	function getChests() public pure returns (Chest[] memory chests) {
		chests = new Chest[](4);
		chests[0] = Chest(0, 1000, 30e18);
		chests[1] = Chest(0, 650, 60e18);
		chests[2] = Chest(0, 350, 100e18);
		chests[3] = Chest(0, 140, 140e18);
	}
}
