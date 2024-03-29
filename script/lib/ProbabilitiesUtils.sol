// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Custom
import { Probabilities } from 'src/lib/ProbabilitiesLib.sol';
import { Settings, ChestConfigs } from 'src/OpenChests.sol';

library ProbabilitiesUtils {
	function sum(uint8[] memory array) private pure returns (uint16 result) {
		uint256 length = array.length;
		for (uint256 i = 0; i < length; ) {
			result += array[i];
			unchecked {
				++i;
			}
		}
	}

	function create(uint8[] memory shares, uint16[] memory results)
		internal
		pure
		returns (Probabilities memory probabilities)
	{
		return
			Probabilities({ sum: sum(shares), shares: shares, results: results });
	}

	function createConfig(
		uint8 chest,
		Settings name,
		uint8[] memory shares,
		uint16[] memory results
	) internal pure returns (ChestConfigs memory config) {
		return
			ChestConfigs({
				chest: chest,
				name: name,
				probabilities: create(shares, results)
			});
	}
}
