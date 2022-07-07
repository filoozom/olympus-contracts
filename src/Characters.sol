// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import {ERC20} from 'solmate/tokens/ERC20.sol';
import {ERC721} from 'solmate/tokens/ERC721.sol';
import {ERC1155} from 'solmate/tokens/ERC1155.sol';
import {SafeTransferLib} from 'solmate/utils/SafeTransferLib.sol';

// Custom
import {OpenChests} from './OpenChests.sol';

contract Characters is ERC721 {
	event Minted(address indexed owner, uint256 indexed id, Rarities rarity);
	event SetName(uint256 indexed id, string name);
	event Evolve(uint256 indexed id, uint256 newLevel);

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

	Character[] public characters;

	constructor(string memory _name, string memory _symbol)
		ERC721(_name, _symbol)
	{}

	function mint(
		address to,
		uint256 id,
		Rarities rarity
	) public {
		uint256 length = characters.length;
		_mint(to, length);
		characters[length] = Character({
			id: id,
			nickname: '',
			level: 1,
			rarity: rarity
		});
		emit Minted(to, id, rarity);
	}

	function setNickname(uint256 id, string calldata nickname) public {
		require(msg.sender == _ownerOf[id], 'NOT_AUTHORIZED');
		characters[id].nickname = nickname;
		emit SetName(id, nickname);
	}

	// Authorized
	function evolve(uint256 id) external {
		emit Evolve(id, ++characters[id].level);
	}

	// ERC721
	function tokenURI(
		uint256 /*id*/
	) public view virtual override returns (string memory) {
		return '';
	}
}
