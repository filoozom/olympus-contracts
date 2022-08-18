// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Solmate
import { Authority } from 'solmate/auth/Auth.sol';

library AuthorityData {
	function getNull() public pure returns (Authority) {
		return Authority(address(0));
	}
}
