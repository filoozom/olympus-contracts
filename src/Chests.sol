// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC721 } from 'solmate/tokens/ERC721.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { SafeTransferLib } from 'solmate/utils/SafeTransferLib.sol';

// Custom
import { Randomness, Probabilities } from './lib/Randomness.sol';
import { Characters } from './Characters.sol';

enum ProbabilityNames {
	EvolvingStone,
	EvolvingPowder,
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
	ProbabilityNames name;
	Probabilities probabilities;
}

contract Chests is ERC1155, Randomness {
	event ChestOpened(address indexed owner, uint256 indexed id);

	ERC20 currency;
	address beneficiary;
	Chest[] chests;
	Characters characters;

	mapping(uint256 => mapping(ProbabilityNames => Probabilities)) probabilities;

	constructor(
		ERC20 _currency,
		address _beneficiary,
		Characters _characters,
		Chest[] memory _chests,
		ChestConfigs[] memory _configs
	) {
		currency = _currency;
		beneficiary = _beneficiary;
		characters = _characters;
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
		_burn(msg.sender, id, amount);
	}
}
