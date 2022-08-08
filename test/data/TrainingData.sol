// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Probabilities } from 'src/lib/Randomness.sol';

// Lib
import { ToDynamicUtils } from '../lib/ToDynamicUtils.sol';
import { ProbabilitiesUtils } from '../lib/ProbabilitiesUtils.sol';

library TrainingData {
	function getProbabilities()
		public
		pure
		returns (Probabilities[] memory probabilities)
	{
		probabilities = new Probabilities[](3);
		probabilities[0] = getProbabilities([uint16(30), 20, 50, 80]);
		probabilities[1] = getProbabilities([uint16(45), 75, 130, 220]);
		probabilities[2] = getProbabilities([uint16(65), 115, 210, 360]);
	}

	function getDurations() public pure returns (uint32[] memory durations) {
		return ToDynamicUtils.toDynamic([uint32(86400), 259200, 604800]);
	}

	function getShares() public pure returns (uint8[] memory shares) {
		return ToDynamicUtils.toDynamic([40, 30, 20, 10]);
	}

	function getProbabilities(uint16[4] memory results)
		private
		pure
		returns (Probabilities memory probabilities)
	{
		return
			ProbabilitiesUtils.create(getShares(), ToDynamicUtils.toDynamic(results));
	}
}
