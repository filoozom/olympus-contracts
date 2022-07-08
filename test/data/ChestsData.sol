// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Probabilities } from 'src/lib/Randomness.sol';
import { ProbabilityNames, ProbabilityConfigs, ProbabilityNames } from 'src/Chests.sol';

// Lib
import { ToDynamicLib } from '../lib/ToDynamicLib.sol';
import { ProbabilitiesLib } from '../lib/ProbabilitiesLib.sol';

library ChestsData {
	function getCommonChestConfigs()
		public
		pure
		returns (ProbabilityConfigs[] memory configs)
	{
		configs = new ProbabilityConfigs[](5);

		// Common chest
		configs[0] = getCommonChestEvolvingStoneConfig();
		configs[1] = getCommonChestEvolvingPowderConfig();
		configs[2] = getCommonChestOlympConfig();
		configs[3] = getCommonChestCharacterRarityConfig();
		configs[4] = getCommonChestCharacterConfig();
	}

	function getCommonChestEvolvingStoneConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingStone,
				ToDynamicLib.toDynamic([9, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getCommonChestEvolvingPowderConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingPowder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(10), 20, 50])
			);
	}

	function getCommonChestOlympConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Olymp,
				ToDynamicLib.toDynamic([70, 15, 12, 3]),
				ToDynamicLib.toDynamic([uint16(0), 200, 400, 800])
			);
	}

	function getCommonChestCharacterRarityConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.CharacterRarity,
				ToDynamicLib.toDynamic([1]),
				ToDynamicLib.toDynamic([uint16(0)])
			);
	}

	function getCommonChestCharacterConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Character,
				ToDynamicLib.toDynamic([5, 3, 2]),
				ToDynamicLib.toDynamic([uint16(0), 1, 2])
			);
	}
}
