// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Lib
import { ToDynamicLib } from '../lib/ToDynamicLib.sol';

library CharactersData {
	function getLevelCosts() public pure returns (uint8[] memory) {
		return ToDynamicLib.toDynamic([4, 8, 16, 24, 30]);
	}
}
