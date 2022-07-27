// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC721 } from 'solmate/tokens/ERC721.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { SafeTransferLib } from 'solmate/utils/SafeTransferLib.sol';

// Custom
import { BurnableBEP20 } from './lib/BurnableBEP20.sol';

enum Rarities {
	Normal,
	Gold,
	Diamond
}

// IDS:
// 0: Medusa
// 1: Apollo
// 2: Achilles
// 3: Titan
// 4: Chimera
// 5: Zeus
struct Character {
	uint256 id;
	string nickname;
	uint8 level;
	Rarities rarity;
}

contract Characters is ERC721 {
	event Minted(address indexed owner, uint256 indexed id, Rarities rarity);
	event SetNickname(uint256 indexed id, string name);
	event Evolve(uint256 indexed id, uint256 newLevel);

	BurnableBEP20 public stones;
	Character[] public characters;
	uint8[] public levelCosts;

	constructor(
		string memory _name,
		string memory _symbol,
		BurnableBEP20 _stones,
		uint8[] memory _levelCosts
	) ERC721(_name, _symbol) {
		stones = _stones;
		levelCosts = _levelCosts;
	}

	function mint(
		address to,
		uint256 id,
		Rarities rarity
	) public {
		require(id < 6, 'UNKNOWN_CHARACTER');
		_mint(to, characters.length);
		characters.push(
			Character({ id: id, nickname: '', level: 1, rarity: rarity })
		);
		emit Minted(to, id, rarity);
	}

	function setNickname(uint256 id, string calldata nickname) public {
		require(msg.sender == _ownerOf[id], 'UNAUTHORIZED');
		characters[id].nickname = nickname;
		emit SetNickname(id, nickname);
	}

	function evolve(uint256 id) public {
		require(msg.sender == _ownerOf[id], 'UNAUTHORIZED');
		Character storage character = characters[id];
		require(character.level < getMaxLevel(id), 'ALREADY_MAX_LEVEL');

		uint8 cost;
		unchecked {
			cost = levelCosts[character.level - 1];
		}

		stones.burnFrom(msg.sender, cost);
		emit Evolve(id, ++character.level);
	}

	function getMaxLevel(uint256 id) public view returns (uint8) {
		Character storage character = characters[id];

		if (character.rarity == Rarities.Diamond) {
			return 6;
		}

		if (character.rarity == Rarities.Gold) {
			return 5;
		}

		return 4;
	}

	// ERC721
	function tokenURI(
		uint256 /*id*/
	) public view virtual override returns (string memory) {
		return '';
	}
}
