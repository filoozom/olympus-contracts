// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Probabilities } from 'src/lib/Randomness.sol';
import { ProbabilityNames, ChestConfigs } from 'src/Chests.sol';

library ProbabilitiesLib {
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
		public
		pure
		returns (Probabilities memory probabilities)
	{
		return
			Probabilities({ sum: sum(shares), shares: shares, results: results });
	}

	function createConfig(
		uint8 chest,
		ProbabilityNames name,
		uint8[] memory shares,
		uint16[] memory results
	) public pure returns (ChestConfigs memory config) {
		return
			ChestConfigs({
				chest: chest,
				name: name,
				probabilities: create(shares, results)
			});
	}
}
