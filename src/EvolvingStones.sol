// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { BurnableERC20 } from './lib/BurnableERC20.sol';
import { MintableERC20 } from './lib/MintableERC20.sol';

contract EvolvingStones is BurnableERC20, MintableERC20 {
	constructor(
		string memory _name,
		string memory _symbol,
		address _owner,
		Authority _authority
	) ERC20(_name, _symbol, 0) MintableERC20(_owner, _authority) {}
}
