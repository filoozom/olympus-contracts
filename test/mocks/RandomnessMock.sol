// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import {Randomness, Probability} from 'src/lib/Randomness.sol';

contract RandomnessMock is Randomness {
	Probability[] probabilities;

	constructor(Probability[] memory _probabilities) {
		uint256 length = _probabilities.length;
		for (uint256 i = 0; i < length; ) {
			probabilities.push(_probabilities[i]);

			unchecked {
				++i;
			}
		}
	}

	function getRandomNumber() public returns (uint16 random) {
		return getRandomUint(probabilities);
	}
}
