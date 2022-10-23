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

contract BonusChests is ERC1155 {
	event ChestOpened(address indexed owner, uint256 indexed id);

	// Chest config
	Chest public chest;

	// Minting configuration
	ERC20 public currency;
	address public beneficiary;
	IOpenChests public openChests;
	uint256 endTimestamp;

	// ERC1155 config
	string private _uri;

	constructor(
		ERC20 _currency,
		address _beneficiary,
		IOpenChests _openChests,
		Chest memory _chest,
		string memory __uri,
		uint256 _endTimestamp
	) {
		// Minting configuration
		currency = _currency;
		beneficiary = _beneficiary;
		openChests = _openChests;
		endTimestamp = _endTimestamp;

		// Chest config
		chest = _chest;

		// ERC1155 config
		_uri = __uri;
	}

	function uri(uint256) public view virtual override returns (string memory) {
		return _uri;
	}

	function mint(uint16 amount) public {
		require(block.timestamp < endTimestamp, 'MINTING_OVER');

		unchecked {
			// max - minted can never be < 0
			require(chest.max - chest.minted >= amount, 'NOT_ENOUGH_LEFT');
		}

		uint256 price;
		unchecked {
			price = chest.price * amount;
			chest.minted += amount;
		}

		SafeTransferLib.safeTransferFrom(currency, msg.sender, beneficiary, price);
		_mint(msg.sender, 4, amount, '');

		if (amount >= 3) {
			_mint(msg.sender, 5, amount / 3, '');
		}
	}

	function open(uint256 id) public {
		// Burn the chest
		_burn(msg.sender, id, 1);
		openChests.mint(msg.sender, id);
		emit ChestOpened(msg.sender, id);
	}
}
