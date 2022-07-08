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
		uint256 i = 0;
		configs = new ProbabilityConfigs[](20);

		// Common chest
		configs[i++] = getCommonChestEvolvingStoneConfig();
		configs[i++] = getCommonChestEvolvingPowderConfig();
		configs[i++] = getCommonChestOlympConfig();
		configs[i++] = getCommonChestCharacterRarityConfig();
		configs[i++] = getCommonChestCharacterConfig();

		// Uncommon chest
		configs[i++] = getUncommonChestEvolvingStoneConfig();
		configs[i++] = getUncommonChestEvolvingPowderConfig();
		configs[i++] = getUncommonChestOlympConfig();
		configs[i++] = getUncommonChestCharacterRarityConfig();
		configs[i++] = getUncommonChestCharacterConfig();

		// Rare chest
		configs[i++] = getRareChestEvolvingStoneConfig();
		configs[i++] = getRareChestEvolvingPowderConfig();
		configs[i++] = getRareChestOlympConfig();
		configs[i++] = getRareChestCharacterRarityConfig();
		configs[i++] = getRareChestCharacterConfig();

		// Legendary chest
		configs[i++] = getLegendaryChestEvolvingStoneConfig();
		configs[i++] = getLegendaryChestEvolvingPowderConfig();
		configs[i++] = getLegendaryChestOlympConfig();
		configs[i++] = getLegendaryChestCharacterRarityConfig();
		configs[i++] = getLegendaryChestCharacterConfig();
	}

	// Common
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
		// TODO: Should only get a character with 40% chance
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

	// Uncommon
	function getUncommonChestEvolvingStoneConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingStone,
				ToDynamicLib.toDynamic([85, 15]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getUncommonChestEvolvingPowderConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingPowder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(20), 40, 100])
			);
	}

	function getUncommonChestOlympConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Olymp,
				ToDynamicLib.toDynamic([60, 20, 16, 4]),
				ToDynamicLib.toDynamic([uint16(0), 400, 800, 1600])
			);
	}

	function getUncommonChestCharacterRarityConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.CharacterRarity,
				ToDynamicLib.toDynamic([8, 2]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getUncommonChestCharacterConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Character,
				ToDynamicLib.toDynamic([35, 30, 25, 10]),
				ToDynamicLib.toDynamic([uint16(0), 1, 2, 3])
			);
	}

	// Rare
	function getRareChestEvolvingStoneConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingStone,
				ToDynamicLib.toDynamic([4, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getRareChestEvolvingPowderConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingPowder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(40), 80, 200])
			);
	}

	function getRareChestOlympConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Olymp,
				ToDynamicLib.toDynamic([50, 25, 20, 5]),
				ToDynamicLib.toDynamic([uint16(0), 800, 1600, 3200])
			);
	}

	function getRareChestCharacterRarityConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.CharacterRarity,
				ToDynamicLib.toDynamic([1, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getRareChestCharacterConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Character,
				ToDynamicLib.toDynamic([35, 30, 25, 10]),
				ToDynamicLib.toDynamic([uint16(1), 2, 3, 4])
			);
	}

	// Legendary
	function getLegendaryChestEvolvingStoneConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingStone,
				ToDynamicLib.toDynamic([3, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getLegendaryChestEvolvingPowderConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.EvolvingPowder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(160), 80, 400])
			);
	}

	function getLegendaryChestOlympConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Olymp,
				ToDynamicLib.toDynamic([40, 30, 24, 6]),
				ToDynamicLib.toDynamic([uint16(0), 1600, 3200, 6400])
			);
	}

	function getLegendaryChestCharacterRarityConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.CharacterRarity,
				ToDynamicLib.toDynamic([3, 1, 1]),
				ToDynamicLib.toDynamic([uint16(1), 0, 2])
			);
	}

	function getLegendaryChestCharacterConfig()
		public
		pure
		returns (ProbabilityConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				ProbabilityNames.Character,
				ToDynamicLib.toDynamic([35, 30, 25, 10]),
				ToDynamicLib.toDynamic([uint16(2), 3, 4, 5])
			);
	}
}
