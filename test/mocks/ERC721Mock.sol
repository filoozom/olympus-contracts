// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { ERC721 } from 'solmate/tokens/ERC721.sol';

contract ERC721Mock is ERC721 {
	constructor(string memory _name, string memory _symbol)
		ERC721(_name, _symbol)
	{}

	function mint(address to, uint256 id) public {
		_mint(to, id);
	}

	function tokenURI(uint256) public pure override returns (string memory) {
		return '';
	}
}
