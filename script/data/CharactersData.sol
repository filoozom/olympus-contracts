// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Lib
import { ToDynamicUtils } from '../lib/ToDynamicUtils.sol';

library CharactersData {
	function getLevelCosts() internal pure returns (uint8[] memory) {
		return ToDynamicUtils.toDynamic([4, 8, 16, 24, 30]);
	}
}
