// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';

contract CurrencyMock is ERC20 {
	constructor(string memory _name, string memory _symbol)
		ERC20(_name, _symbol, 18)
	{}
}
