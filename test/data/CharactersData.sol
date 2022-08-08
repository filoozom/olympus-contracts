// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Lib
import { ToDynamicUtils } from '../lib/ToDynamicUtils.sol';

library CharactersData {
	function getLevelCosts() public pure returns (uint8[] memory) {
		return ToDynamicUtils.toDynamic([4, 8, 16, 24, 30]);
	}
}
