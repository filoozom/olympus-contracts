// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { Authority } from 'solmate/auth/Auth.sol';

library AuthorityData {
	function getNull() public pure returns (Authority) {
		return Authority(address(0));
	}
}
