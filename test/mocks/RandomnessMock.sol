// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import {Randomness, Probabilities} from 'src/lib/Randomness.sol';

contract RandomnessMock is Randomness {
	Probabilities probabilities;

	constructor(Probabilities memory _probabilities) {
		probabilities = _probabilities;
	}

	function getRandomNumber() public returns (uint16 random) {
		return getRandomUint(probabilities);
	}
}
