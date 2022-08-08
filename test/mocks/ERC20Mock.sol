// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';

contract ERC20Mock is ERC20 {
	constructor(string memory _name, string memory _symbol)
		ERC20(_name, _symbol, 18)
	{}

	function mint(address to, uint256 amount) public {
		_mint(to, amount);
	}
}
