// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { Auth, Authority } from 'solmate/auth/Auth.sol';
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC721 } from 'solmate/tokens/ERC721.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { SafeTransferLib } from 'solmate/utils/SafeTransferLib.sol';

// Custom
import { IERC165 } from './interfaces/IERC165.sol';

struct Listing {
	address owner;
	address token;
	uint256 id;
	uint256 amount;
	uint256 price;
}

enum Types {
	Unsupported,
	ERC20,
	ERC721,
	ERC1155
}

contract Marketplace is Auth {
	ERC20 public currency;
	mapping(address => Types) public allowedTokens;
	mapping(uint256 => Listing) public listings;
	uint256 private listingCount = 0;

	constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}

	// Marketplace
	function listERC20(
		address token,
		uint256 amount,
		uint256 price
	) public {
		require(allowedTokens[token] == Types.ERC20, 'UNSUPPORTED_TOKEN');

		SafeTransferLib.safeTransferFrom(
			ERC20(token),
			msg.sender,
			address(this),
			amount
		);
		createListing(token, 0, amount, price);
	}

	function listERC721(
		address token,
		uint256 id,
		uint256 price
	) public {
		require(allowedTokens[token] == Types.ERC721, 'UNSUPPORTED_TOKEN');

		ERC721(token).safeTransferFrom(msg.sender, address(this), id);
		createListing(token, id, 1, price);
	}

	function listERC1155(
		address token,
		uint256 id,
		uint256 amount,
		uint256 price
	) public {
		require(allowedTokens[token] == Types.ERC1155, 'UNSUPPORTED_TOKEN');

		ERC1155(token).safeTransferFrom(msg.sender, address(this), id, amount, '');
		createListing(token, id, amount, price);
	}

	function cancelERC20(uint256 id) public {
		Listing storage listing = listings[id];
		require(listing.owner == msg.sender, 'UNAUTHORIZED');

		SafeTransferLib.safeTransferFrom(
			ERC20(listing.token),
			address(this),
			msg.sender,
			listing.amount
		);

		delete listings[id];
	}

	function cancelERC721(uint256 id) public {
		Listing storage listing = listings[id];
		require(listing.owner == msg.sender, 'UNAUTHORIZED');

		ERC721(listing.token).safeTransferFrom(
			address(this),
			msg.sender,
			listing.id
		);

		delete listings[id];
	}

	function cancelERC1155(uint256 id) public {
		Listing storage listing = listings[id];
		require(listing.owner == msg.sender, 'UNAUTHORIZED');

		ERC1155(listing.token).safeTransferFrom(
			address(this),
			msg.sender,
			listing.id,
			listing.amount,
			''
		);

		delete listings[id];
	}

	function buyERC20(uint256 id) public {
		Listing storage listing = listings[id];

		SafeTransferLib.safeTransferFrom(
			currency,
			msg.sender,
			listing.owner,
			listing.price
		);
		SafeTransferLib.safeTransferFrom(
			ERC20(listing.token),
			address(this),
			msg.sender,
			listing.amount
		);

		delete listings[id];
	}

	function buyERC721(uint256 id) public {
		Listing storage listing = listings[id];

		SafeTransferLib.safeTransferFrom(
			currency,
			msg.sender,
			listing.owner,
			listing.price
		);
		ERC721(listing.token).safeTransferFrom(
			address(this),
			msg.sender,
			listing.id
		);

		delete listings[id];
	}

	function buyERC1155(uint256 id) public {
		Listing storage listing = listings[id];

		SafeTransferLib.safeTransferFrom(
			currency,
			msg.sender,
			listing.owner,
			listing.price
		);
		ERC1155(listing.token).safeTransferFrom(
			address(this),
			msg.sender,
			listing.id,
			listing.amount,
			''
		);

		delete listings[id];
	}

	// Admin
	function allowToken(address token) public requiresAuth {
		allowedTokens[token] = getType(IERC165(token));
	}

	function disallowToken(address token) public requiresAuth {
		allowedTokens[token] = Types.Unsupported;
	}

	// Private
	function getType(IERC165 token) private view returns (Types) {
		if (token.supportsInterface(0x80ac58cd)) {
			return Types.ERC721;
		}

		if (token.supportsInterface(0xd9b67a26)) {
			return Types.ERC1155;
		}

		revert('INCOMPATIBLE_CONTRACT');
	}

	function createListing(
		address token,
		uint256 id,
		uint256 amount,
		uint256 price
	) public {
		listings[listingCount] = Listing({
			owner: msg.sender,
			token: token,
			id: id,
			amount: amount,
			price: price
		});

		unchecked {
			listingCount++;
		}
	}
}
