// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Probability {
	uint8 probability;
	uint16 result;
}

abstract contract Randomness {
	uint256 seed;

	constructor() {
		initRandom();
	}

	function initRandom() private {
		seed = uint256(
			keccak256(
				abi.encodePacked(
					blockhash(block.number - 1),
					block.coinbase,
					block.difficulty
				)
			)
		);
	}

	function getRandom() internal returns (uint256 random) {
		seed = uint256(
			keccak256(
				abi.encodePacked(
					seed,
					blockhash(block.number - ((seed % 63) + 1)),
					block.coinbase,
					block.difficulty
				)
			)
		);
		return seed;
	}

	function getRandomUint(Probability[] storage probabilities)
		internal
		returns (uint16 random)
	{
		uint256 number = getRandom() % 100;
		uint8 total = 0;
		uint256 length = probabilities.length;

		for (uint8 i = 0; i < length; ) {
			Probability storage probability = probabilities[i];
			unchecked {
				total += probability.probability;
			}

			if (number < total) {
				return probability.result;
			}

			unchecked {
				i++;
			}
		}
	}
}
