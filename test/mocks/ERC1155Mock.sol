// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Solmate
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';

contract ERC1155Mock is ERC1155 {
	function mint(
		address to,
		uint256 id,
		uint256 amount
	) public {
		_mint(to, id, amount, '');
	}

	function uri(uint256) public pure override returns (string memory) {
		return '';
	}
}
