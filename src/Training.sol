// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import { Characters } from './Characters.sol';
import { MintableBEP20 } from './lib/MintableBEP20.sol';
import { Randomness, Probabilities } from './lib/Randomness.sol';

enum Durations {
	OneDay,
	ThreeDays,
	SevenDays
}

struct Session {
	uint64 end;
	Durations time;
}

contract Training is Randomness {
	Characters public characters;
	mapping(uint256 => Session) public sessions;
	MintableBEP20 public powder;

	Probabilities[] public probabilities;
	uint32[] public durations;

	constructor(
		Characters _characters,
		MintableBEP20 _powder,
		uint32[] memory _durations,
		Probabilities[] memory _probabilities
	) {
		characters = _characters;
		powder = _powder;
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

	function train(uint256 id, Durations time) public {
		uint64 duration = durations[uint8(time)];
		require(sessions[id].end == 0, 'ALREADY_TRAINING');
		require(characters.ownerOf(id) == msg.sender, 'UNAUTHORIZED');

		sessions[id] = Session({
			end: uint64(block.timestamp) + duration,
			time: time
		});
	}

	function endTrain(uint256 id) public {
		Session storage training = sessions[id];
		require(training.end > 0, 'NOT_TRAINING');
		require(block.timestamp >= training.end, 'NOT_DONE');
		require(characters.ownerOf(id) == msg.sender, 'UNAUTHORIZED');

		// More gas efficient than `delete sessions[id]`
		training.end = 0;

		powder.mint(msg.sender, getRandomUint(probabilities[uint8(training.time)]));
	}
}
