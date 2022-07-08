// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { Auth, Authority } from 'solmate/auth/Auth.sol';

abstract contract MintableERC20 is ERC20, Auth {
	constructor(address _owner, Authority _authority)
		Auth(_owner, _authority)
	{}

	function mint(address to, uint256 amount) public requiresAuth {
		_mint(to, amount);
	}
}
