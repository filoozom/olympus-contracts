// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice Probability that some result happens based on its shares
/// @notice The probability of getting results[0] is shares[0] / sum
/// @dev sum needs to be equal to the sum of shares
/// @dev the length of the shares and results arrays need to be equal
struct Probabilities {
	uint16 sum;
	uint8[] shares;
	uint16[] results;
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

	function getRandomUint(Probabilities storage probabilities)
		internal
		returns (uint16 random)
	{
		uint256 number = getRandom() % probabilities.sum;
		uint256 length = probabilities.shares.length;
		uint8 total = 0;

		for (uint8 i = 0; i < length; ) {
			unchecked {
				total += probabilities.shares[i];
			}

			if (number < total) {
				return probabilities.results[i];
			}

			unchecked {
				i++;
			}
		}
	}
}
