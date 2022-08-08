// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Probabilities } from 'src/lib/ProbabilitiesLib.sol';
import { Settings, ChestConfigs, Settings } from 'src/OpenChests.sol';

// Lib
import { ToDynamicUtils } from '../lib/ToDynamicUtils.sol';
import { ProbabilitiesUtils } from '../lib/ProbabilitiesUtils.sol';

library OpenChestsData {
	function getConfigs() public pure returns (ChestConfigs[] memory configs) {
		uint256 i = 0;
		configs = new ChestConfigs[](20);

		// Common chest
		configs[i++] = getCommonChestEvolvingStoneConfig();
		configs[i++] = getCommonChestPowderConfig();
		configs[i++] = getCommonChestOlympConfig();
		configs[i++] = getCommonChestCharacterRarityConfig();
		configs[i++] = getCommonChestCharacterConfig();

		// Uncommon chest
		configs[i++] = getUncommonChestEvolvingStoneConfig();
		configs[i++] = getUncommonChestPowderConfig();
		configs[i++] = getUncommonChestOlympConfig();
		configs[i++] = getUncommonChestCharacterRarityConfig();
		configs[i++] = getUncommonChestCharacterConfig();

		// Rare chest
		configs[i++] = getRareChestEvolvingStoneConfig();
		configs[i++] = getRareChestPowderConfig();
		configs[i++] = getRareChestOlympConfig();
		configs[i++] = getRareChestCharacterRarityConfig();
		configs[i++] = getRareChestCharacterConfig();

		// Legendary chest
		configs[i++] = getLegendaryChestEvolvingStoneConfig();
		configs[i++] = getLegendaryChestPowderConfig();
		configs[i++] = getLegendaryChestOlympConfig();
		configs[i++] = getLegendaryChestCharacterRarityConfig();
		configs[i++] = getLegendaryChestCharacterConfig();
	}

	// Common
	function getCommonChestEvolvingStoneConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				0,
				Settings.EvolvingStone,
				ToDynamicUtils.toDynamic([9, 1]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getCommonChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				0,
				Settings.Powder,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(10), 20, 50])
			);
	}

	function getCommonChestOlympConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				0,
				Settings.Olymp,
				ToDynamicUtils.toDynamic([70, 15, 12, 3]),
				ToDynamicUtils.toDynamic([uint16(0), 200, 400, 800])
			);
	}

	function getCommonChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				0,
				Settings.CharacterRarity,
				ToDynamicUtils.toDynamic([1, 1]),
				ToDynamicUtils.toDynamic([type(uint16).max, 0])
			);
	}

	function getCommonChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				0,
				Settings.Character,
				ToDynamicUtils.toDynamic([5, 3, 2]),
				ToDynamicUtils.toDynamic([uint16(0), 1, 2])
			);
	}

	// Uncommon
	function getUncommonChestEvolvingStoneConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				1,
				Settings.EvolvingStone,
				ToDynamicUtils.toDynamic([85, 15]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getUncommonChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				1,
				Settings.Powder,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(20), 40, 100])
			);
	}

	function getUncommonChestOlympConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				1,
				Settings.Olymp,
				ToDynamicUtils.toDynamic([60, 20, 16, 4]),
				ToDynamicUtils.toDynamic([uint16(0), 400, 800, 1600])
			);
	}

	function getUncommonChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				1,
				Settings.CharacterRarity,
				ToDynamicUtils.toDynamic([8, 2]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getUncommonChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				1,
				Settings.Character,
				ToDynamicUtils.toDynamic([35, 30, 25, 10]),
				ToDynamicUtils.toDynamic([uint16(0), 1, 2, 3])
			);
	}

	// Rare
	function getRareChestEvolvingStoneConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				2,
				Settings.EvolvingStone,
				ToDynamicUtils.toDynamic([4, 1]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getRareChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				2,
				Settings.Powder,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(40), 80, 200])
			);
	}

	function getRareChestOlympConfig() public pure returns (ChestConfigs memory) {
		return
			ProbabilitiesUtils.createConfig(
				2,
				Settings.Olymp,
				ToDynamicUtils.toDynamic([50, 25, 20, 5]),
				ToDynamicUtils.toDynamic([uint16(0), 800, 1600, 3200])
			);
	}

	function getRareChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				2,
				Settings.CharacterRarity,
				ToDynamicUtils.toDynamic([1, 1]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getRareChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				2,
				Settings.Character,
				ToDynamicUtils.toDynamic([35, 30, 25, 10]),
				ToDynamicUtils.toDynamic([uint16(1), 2, 3, 4])
			);
	}

	// Legendary
	function getLegendaryChestEvolvingStoneConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				3,
				Settings.EvolvingStone,
				ToDynamicUtils.toDynamic([3, 1]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getLegendaryChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				3,
				Settings.Powder,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(160), 80, 400])
			);
	}

	function getLegendaryChestOlympConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				3,
				Settings.Olymp,
				ToDynamicUtils.toDynamic([40, 30, 24, 6]),
				ToDynamicUtils.toDynamic([uint16(0), 1600, 3200, 6400])
			);
	}

	function getLegendaryChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				3,
				Settings.CharacterRarity,
				ToDynamicUtils.toDynamic([3, 1, 1]),
				ToDynamicUtils.toDynamic([uint16(1), 0, 2])
			);
	}

	function getLegendaryChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				3,
				Settings.Character,
				ToDynamicUtils.toDynamic([35, 30, 25, 10]),
				ToDynamicUtils.toDynamic([uint16(2), 3, 4, 5])
			);
	}
}
