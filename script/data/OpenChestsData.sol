// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Custom
import { Probabilities } from 'src/lib/ProbabilitiesLib.sol';
import { Settings, ChestConfigs, Settings } from 'src/OpenChests.sol';

// Lib
import { ToDynamicUtils } from '../lib/ToDynamicUtils.sol';
import { ProbabilitiesUtils } from '../lib/ProbabilitiesUtils.sol';

library OpenChestsData {
	function getConfigs() internal pure returns (ChestConfigs[] memory configs) {
		uint256 i = 0;
		configs = new ChestConfigs[](10);

		// Atlas Legendary chest
		configs[i++] = getAtlasLegendaryChestEvolvingStoneConfig();
		configs[i++] = getAtlasLegendaryChestPowderConfig();
		configs[i++] = getAtlasLegendaryChestOlympConfig();
		configs[i++] = getAtlasLegendaryChestCharacterRarityConfig();
		configs[i++] = getAtlasLegendaryChestCharacterConfig();

		// Bonus chest
		configs[i++] = getBonusChestEvolvingStoneConfig();
		configs[i++] = getBonusChestPowderConfig();
		configs[i++] = getBonusChestOlympConfig();
		configs[i++] = getBonusChestCharacterRarityConfig();
		configs[i++] = getBonusChestCharacterConfig();
	}

	// Atlas Legendary
	function getAtlasLegendaryChestEvolvingStoneConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				4,
				Settings.EvolvingStone,
				ToDynamicUtils.toDynamic([3, 1]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getAtlasLegendaryChestPowderConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				4,
				Settings.Powder,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(40), 80, 200])
			);
	}

	function getAtlasLegendaryChestOlympConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				4,
				Settings.Olymp,
				ToDynamicUtils.toDynamic([20, 15, 12, 3]),
				ToDynamicUtils.toDynamic([uint16(0), 800, 1600, 3200])
			);
	}

	function getAtlasLegendaryChestCharacterRarityConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				4,
				Settings.CharacterRarity,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(0), 1, 2])
			);
	}

	function getAtlasLegendaryChestCharacterConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				4,
				Settings.Character,
				ToDynamicUtils.toDynamic([11, 7, 2]),
				ToDynamicUtils.toDynamic([uint16(6), 7, 8])
			);
	}

	// Bonus
	function getBonusChestEvolvingStoneConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				5,
				Settings.EvolvingStone,
				ToDynamicUtils.toDynamic([3, 1]),
				ToDynamicUtils.toDynamic([uint16(0), 1])
			);
	}

	function getBonusChestPowderConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				5,
				Settings.Powder,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(80), 160, 400])
			);
	}

	function getBonusChestOlympConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				5,
				Settings.Olymp,
				ToDynamicUtils.toDynamic([5, 4, 1]),
				ToDynamicUtils.toDynamic([uint16(600), 800, 1000])
			);
	}

	function getBonusChestCharacterRarityConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				5,
				Settings.CharacterRarity,
				ToDynamicUtils.toDynamic([1, 1]),
				ToDynamicUtils.toDynamic([type(uint16).max, 0])
			);
	}

	function getBonusChestCharacterConfig()
		internal
		pure
		returns (ChestConfigs memory)
	{
		return
			ProbabilitiesUtils.createConfig(
				5,
				Settings.Character,
				ToDynamicUtils.toDynamic([1]),
				ToDynamicUtils.toDynamic([uint16(9)])
			);
	}
}
