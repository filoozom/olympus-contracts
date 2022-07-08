// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Characters } from './Characters.sol';
import { MintableERC20 } from './lib/MintableERC20.sol';
import { Randomness, Probabilities } from './lib/Randomness.sol';

struct Session {
	uint256 end;
	uint8 time;
}

contract Training is Randomness {
	Characters public characters;
	mapping(uint256 => Session) public sessions;
	MintableERC20 public powder;

	Probabilities[] public probabilities;
	uint32[] public durations;

	constructor(
		Characters _characters,
		uint32[] memory _durations,
		Probabilities[] memory _probabilities
	) {
		characters = _characters;
		durations = _durations;
		setProbabilities(_probabilities);
	}

	function setProbabilities(Probabilities[] memory _probabilities) private {
		uint256 length = _probabilities.length;
		for (uint256 i = 0; i < length; ) {
			probabilities.push(_probabilities[i]);
			unchecked {
				++i;
			}
		}
	}

	function train(uint256 id, uint8 time) public {
		uint256 duration = durations[time];
		require(duration > 0, 'WRONG_DURATION');
		require(sessions[id].end == 0, 'ALREADY_TRAINING');
		require(characters.ownerOf(id) == msg.sender, 'NOT_AUTHORIZED');

		sessions[id] = Session({ end: block.timestamp + duration, time: time });
	}

	function endTrain(uint256 id) public {
		Session storage training = sessions[id];
		require(training.end > block.timestamp, 'NOT_DONE');
		require(characters.ownerOf(id) == msg.sender, 'NOT_AUTHORIZED');

		training.end = 0;

		powder.mint(msg.sender, getRandomUint(probabilities[training.time]));
	}
}
