// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Custom
import { Chest } from 'src/BonusChests.sol';

library BonusChestsData {
	function getChest() internal pure returns (Chest memory chest) {
		chest = Chest(0, 350, 140e18);
	}
}
