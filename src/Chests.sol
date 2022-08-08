// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { SafeTransferLib } from 'solmate/utils/SafeTransferLib.sol';

// Custom
import { IOpenChests } from './interfaces/IOpenChests.sol';

struct Chest {
	uint16 minted;
	uint16 max;
	uint224 price;
}

contract Chests is ERC1155 {
	event ChestOpened(address indexed owner, uint256 indexed id);

	// Chest config
	Chest[] public chests;

	// Minting configuration
	ERC20 public currency;
	address public beneficiary;
	IOpenChests public openChests;

	constructor(
		ERC20 _currency,
		address _beneficiary,
		IOpenChests _openChests,
		Chest[] memory _chests
	) {
		// Minting configuration
		currency = _currency;
		beneficiary = _beneficiary;
		openChests = _openChests;

		// Chest config
		setChests(_chests);
	}

	function setChests(Chest[] memory _chests) private {
		uint256 length = _chests.length;
		for (uint256 i = 0; i < length; ) {
			chests.push(_chests[i]);
			unchecked {
				++i;
			}
		}
	}

	function uri(uint256) public view virtual override returns (string memory) {
		return '';
	}

	function mint(uint256 id, uint16 amount) public {
		Chest storage chest = chests[id];
		unchecked {
			// max - minted can never be < 0
			require(chest.max - chest.minted >= amount, 'NOT_ENOUGH_LEFT');
		}

		uint256 price;
		unchecked {
			price = chest.price * amount;
		}

		SafeTransferLib.safeTransferFrom(currency, msg.sender, beneficiary, price);
		_mint(msg.sender, id, amount, '');
		chest.minted += amount;
	}

	function open(uint256 id) public {
		// Burn the chest
		_burn(msg.sender, id, 1);
		openChests.mint(msg.sender, id);
		emit ChestOpened(msg.sender, id);
	}
}
