// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC721 } from 'solmate/tokens/ERC721.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { SafeTransferLib } from 'solmate/utils/SafeTransferLib.sol';

// Custom
import { Randomness, Probabilities } from './lib/Randomness.sol';
import { MintableERC20 } from './lib/MintableERC20.sol';
import { Characters, Rarities } from './Characters.sol';

enum Settings {
	EvolvingStone,
	Powder,
	Olymp,
	CharacterRarity,
	Character
}

struct Chest {
	uint256 minted;
	uint256 max;
	uint256 price;
}

struct ChestConfigs {
	uint8 chest;
	Settings name;
	Probabilities probabilities;
}

contract Chests is ERC1155, Randomness {
	event ChestOpened(address indexed owner, uint256 indexed id);

	// Chest config
	Chest[] chests;
	mapping(uint256 => mapping(Settings => Probabilities)) probabilities;

	// Minting configuration
	ERC20 currency;
	address beneficiary;

	// Resources to mint on chest opening
	Characters characters;
	MintableERC20 olymp;
	MintableERC20 powder;
	MintableERC20 evolvingStones;

	constructor(
		ERC20 _currency,
		address _beneficiary,
		Characters _characters,
		MintableERC20 _olymp,
		MintableERC20 _powder,
		MintableERC20 _evolvingStones,
		Chest[] memory _chests,
		ChestConfigs[] memory _configs
	) {
		// Minting configuration
		currency = _currency;
		beneficiary = _beneficiary;

		// Resources to mint on chest opening
		characters = _characters;
		olymp = _olymp;
		powder = _powder;
		evolvingStones = _evolvingStones;

		// Chest config
		setChests(_chests);
		setConfigs(_configs);
	}

	function setConfigs(ChestConfigs[] memory _configs) private {
		uint256 length = _configs.length;
		for (uint256 i = 0; i < length; ) {
			ChestConfigs memory config = _configs[i];
			probabilities[config.chest][config.name] = config.probabilities;
			unchecked {
				++i;
			}
		}
	}

	function setChests(Chest[] memory _chests) private {
		uint256 length = _chests.length;
		for (uint256 i = 0; i < length; ) {
			chests[i] = _chests[i];
			unchecked {
				++i;
			}
		}
	}

	function uri(uint256) public view virtual override returns (string memory) {
		return '';
	}

	function mint(uint256 id, uint256 amount) public {
		Chest storage chest = chests[id];
		unchecked {
			require(chest.max - chest.minted <= amount, 'NOT_ENOUGH_LEFT');
		}

		uint256 price;
		unchecked {
			price = chest.price * amount;
		}

		SafeTransferLib.safeTransferFrom(currency, msg.sender, beneficiary, price);
		_mint(msg.sender, id, amount, '');
	}

	function open(uint256 id, uint32 amount) public {
		// Burn the chest
		_burn(msg.sender, id, amount);

		// Get large random number
		uint16 result;
		uint256 random = getRandom();

		// Get evolving stones to mint
		(result, random) = getProbability(id, Settings.EvolvingStone, random);
		if (result > 0) {
			evolvingStones.mint(msg.sender, result);
		}

		// Get powder to mint
		(result, random) = getProbability(id, Settings.Powder, random);
		if (result > 0) {
			powder.mint(msg.sender, result);
		}

		// Get OLYMP to mint
		(result, random) = getProbability(id, Settings.Olymp, random);
		if (result > 0) {
			olymp.mint(msg.sender, result);
		}

		// Get rarity of the character to mint
		(result, random) = getProbability(id, Settings.CharacterRarity, random);

		// If the rarity is invalid, it means no character should be minted
		if (result > uint16(type(Rarities).max)) {
			return;
		}

		// Keep rarity to set on the character
		Rarities rarity = Rarities(result);

		// Mint character
		(result, random) = getProbability(id, Settings.Character, random);
		characters.mint(msg.sender, result, rarity);
	}

	function getProbability(
		uint256 id,
		Settings name,
		uint256 random
	) internal view returns (uint16, uint256) {
		Probabilities storage prob = probabilities[id][name];
		return (getRandomUint(prob, random), random / prob.sum);
	}
}
