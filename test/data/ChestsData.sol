// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Probabilities } from 'src/lib/Randomness.sol';
import { Settings, ChestConfigs, Settings, Chests } from 'src/Chests.sol';

// Lib
import { ToDynamicLib } from '../lib/ToDynamicLib.sol';
import { ProbabilitiesLib } from '../lib/ProbabilitiesLib.sol';

library ChestsData {
	function getChests() public pure returns (Chest[] memory chests) {
		chests = new Chest[](4);
		chests[0] = Chest(0, 1000, 40e18);
		chests[1] = Chest(0, 500, 80e18);
		chests[2] = Chest(0, 250, 160e18);
		chests[3] = Chest(0, 140, 300e18);
	}

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
			ProbabilitiesLib.createConfig(
				0,
				Settings.EvolvingStone,
				ToDynamicLib.toDynamic([9, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getCommonChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Powder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(10), 20, 50])
			);
	}

	function getCommonChestOlympConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Olymp,
				ToDynamicLib.toDynamic([70, 15, 12, 3]),
				ToDynamicLib.toDynamic([uint16(0), 200, 400, 800])
			);
	}

	function getCommonChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.CharacterRarity,
				ToDynamicLib.toDynamic([6, 4]),
				ToDynamicLib.toDynamic([type(uint16).max, 0])
			);
	}

	function getCommonChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Character,
				ToDynamicLib.toDynamic([5, 3, 2]),
				ToDynamicLib.toDynamic([uint16(0), 1, 2])
			);
	}

	// Uncommon
	function getUncommonChestEvolvingStoneConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.EvolvingStone,
				ToDynamicLib.toDynamic([85, 15]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getUncommonChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Powder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(20), 40, 100])
			);
	}

	function getUncommonChestOlympConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Olymp,
				ToDynamicLib.toDynamic([60, 20, 16, 4]),
				ToDynamicLib.toDynamic([uint16(0), 400, 800, 1600])
			);
	}

	function getUncommonChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.CharacterRarity,
				ToDynamicLib.toDynamic([8, 2]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getUncommonChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Character,
				ToDynamicLib.toDynamic([35, 30, 25, 10]),
				ToDynamicLib.toDynamic([uint16(0), 1, 2, 3])
			);
	}

	// Rare
	function getRareChestEvolvingStoneConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.EvolvingStone,
				ToDynamicLib.toDynamic([4, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getRareChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Powder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(40), 80, 200])
			);
	}

	function getRareChestOlympConfig() public pure returns (ChestConfigs memory) {
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Olymp,
				ToDynamicLib.toDynamic([50, 25, 20, 5]),
				ToDynamicLib.toDynamic([uint16(0), 800, 1600, 3200])
			);
	}

	function getRareChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.CharacterRarity,
				ToDynamicLib.toDynamic([1, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getRareChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Character,
				ToDynamicLib.toDynamic([35, 30, 25, 10]),
				ToDynamicLib.toDynamic([uint16(1), 2, 3, 4])
			);
	}

	// Legendary
	function getLegendaryChestEvolvingStoneConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.EvolvingStone,
				ToDynamicLib.toDynamic([3, 1]),
				ToDynamicLib.toDynamic([uint16(0), 1])
			);
	}

	function getLegendaryChestPowderConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Powder,
				ToDynamicLib.toDynamic([5, 4, 1]),
				ToDynamicLib.toDynamic([uint16(160), 80, 400])
			);
	}

	function getLegendaryChestOlympConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Olymp,
				ToDynamicLib.toDynamic([40, 30, 24, 6]),
				ToDynamicLib.toDynamic([uint16(0), 1600, 3200, 6400])
			);
	}

	function getLegendaryChestCharacterRarityConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.CharacterRarity,
				ToDynamicLib.toDynamic([3, 1, 1]),
				ToDynamicLib.toDynamic([uint16(1), 0, 2])
			);
	}

	function getLegendaryChestCharacterConfig()
		public
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesLib.createConfig(
				0,
				Settings.Character,
				ToDynamicLib.toDynamic([35, 30, 25, 10]),
				ToDynamicLib.toDynamic([uint16(2), 3, 4, 5])
			);
	}
}
