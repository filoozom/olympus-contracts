// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Solmate
import { Auth, Authority } from 'solmate/auth/Auth.sol';
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC1155, ERC1155TokenReceiver } from 'solmate/tokens/ERC1155.sol';
import { SafeTransferLib } from 'solmate/utils/SafeTransferLib.sol';

// Custom
import { IOpenChests } from './interfaces/IOpenChests.sol';

struct Chest {
	uint16 minted;
	uint16 max;
	uint224 price;
}

contract Chests is ERC1155, Auth {
	event ChestOpened(address indexed owner, uint256 indexed id);

	// Chest config
	Chest[] public chests;

	// Minting configuration
	ERC20 public currency;
	address public beneficiary;
	IOpenChests public openChests;
	uint256 endTimestamp;

	// ERC1155 config
	string private _uri;

	constructor(
		address _owner,
		Authority _authority,
		ERC20 _currency,
		address _beneficiary,
		IOpenChests _openChests,
		Chest[] memory _chests,
		string memory __uri,
		uint256 _endTimestamp
	) Auth(_owner, _authority) {
		// Minting configuration
		currency = _currency;
		beneficiary = _beneficiary;
		openChests = _openChests;
		endTimestamp = _endTimestamp;

		// Chest config
		setChests(_chests);

		// ERC1155 config
		_uri = __uri;
	}

	function setChests(Chest[] memory _chests) public requiresAuth {
		uint256 length = _chests.length;
		for (uint256 i = 0; i < length; ) {
			chests.push(_chests[i]);
			unchecked {
				++i;
			}
		}
	}

	function uri(uint256) public view virtual override returns (string memory) {
		return _uri;
	}

	function mint(uint256 id, uint16 amount) public {
		require(block.timestamp < endTimestamp, 'MINTING_OVER');

		Chest storage chest = chests[id];
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
		_mint(msg.sender, id, amount, '');
	}

	function batchMint(uint256[] calldata ids, uint256[] calldata amounts)
		public
	{
		batchMint(msg.sender, ids, amounts, false);
	}

	function batchMintFree(
		address to,
		uint256[] memory ids,
		uint256[] memory amounts
	) public requiresAuth {
		batchMint(to, ids, amounts, true);
	}

	function batchMint(
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bool free
	) private {
		require(ids.length == amounts.length, 'LENGTH_MISMATCH');
		uint256 price;

		// Storing these outside the loop saves some gas per iteration.
		uint256 id;
		uint256 amount;
		Chest storage chest;

		for (uint256 i = 0; i < ids.length; ) {
			id = ids[i];
			amount = amounts[i];
			chest = chests[id];

			unchecked {
				// max - minted can never be < 0
				require(chest.max - chest.minted >= amount, 'NOT_ENOUGH_LEFT');
			}

			unchecked {
				chest.minted += uint16(amount);
				price += chest.price * amount;
				++i;
			}
		}

		if (!free) {
			SafeTransferLib.safeTransferFrom(currency, to, beneficiary, price);
		}

		_batchMint(to, ids, amounts, '');
	}

	function open(uint256 id) public {
		// Burn the chest
		_burn(msg.sender, id, 1);
		openChests.mint(msg.sender, id);
		emit ChestOpened(msg.sender, id);
	}
}
