// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import {ERC20} from 'solmate/tokens/ERC20.sol';
import {ERC721} from 'solmate/tokens/ERC721.sol';
import {ERC1155} from 'solmate/tokens/ERC1155.sol';
import {SafeTransferLib} from 'solmate/utils/SafeTransferLib.sol';

// Custom
import {OpenChests} from './OpenChests.sol';

enum Characters {
	Medusa,
	Apollo,
	Achilles,
	Titan,
	Chimera,
	Zeus
}

contract Chests is ERC1155 {
	struct Chest {
		uint256 minted;
		uint256 max;
		uint256 price;
	}

	event ChestOpened(address indexed owner, uint256 indexed id);

	ERC20 currency;
	address beneficiary;
	Chest[] chests;
	ERC1155 characters;
	OpenChests openChests;

	constructor(
		ERC20 _currency,
		address _beneficiary,
		ERC1155 _characters,
		Chest[] memory _chests
	) {
		currency = _currency;
		beneficiary = _beneficiary;
		characters = _characters;

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

		SafeTransferLib.safeTransferFrom(
			currency,
			msg.sender,
			beneficiary,
			price
		);
		_mint(msg.sender, id, amount, '');
	}

	function open(uint256 id, uint32 amount) public {
		_burn(msg.sender, id, amount);
		openChests.mint(msg.sender, id, amount);
	}
}
