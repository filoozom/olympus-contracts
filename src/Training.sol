// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Custom
import {Characters} from './Characters.sol';
import {MintableERC20} from './lib/MintableERC20.sol';
import {Randomness, Probability} from './lib/Randomness.sol';

struct Config {
	uint32 duration;
	Probability[] probabilities;
}

struct Session {
	uint256 end;
	uint8 duration;
}

contract Training is Randomness {
	/*
  Config[] config = [
    Config(86400, [[30, 20], [40, 30], [20, 50], [10, 80]]),
    Config(259200, [[30, 45], [40, 75], [20, 130], [10, 220]]),
    Config(604800,  [[30, 65], [40, 115], [20, 210], [10, 360]])
  ];
  */

	Characters public characters;
	mapping(uint256 => Session) public sessions;
	MintableERC20 public powder;
	Config[] public configs;

	Probability[][] public probabilities;
	uint32[] public durations;

	constructor(
		Characters _characters,
		uint32[] memory _durations,
		Probability[][] memory _probabilities
	) {
		characters = _characters;
		durations = _durations;

		uint256 iLength = _probabilities.length;
		for (uint256 i = 0; i < iLength; ) {
			uint256 jLength = _probabilities[i].length;
			Probability[] storage probability = probabilities.push();

			for (uint256 j = 0; j < jLength; ) {
				probability.push(_probabilities[i][j]);

				unchecked {
					++j;
				}
			}

			unchecked {
				++i;
			}
		}
	}

	function train(uint256 id, uint8 duration) public {
		Config storage config = configs[duration];
		require(config.duration > 0, 'WRONG_DURATION');
		require(sessions[id].end == 0, 'ALREADY_TRAINING');
		require(characters.ownerOf(id) == msg.sender, 'NOT_AUTHORIZED');

		sessions[id] = Session({
			end: block.timestamp + config.duration,
			duration: duration
		});
	}

	function endTrain(uint256 id) public {
		Session storage training = sessions[id];
		require(training.end > block.timestamp, 'NOT_DONE');
		require(characters.ownerOf(id) == msg.sender, 'NOT_AUTHORIZED');

		training.end = 0;

		Config storage config = configs[training.duration];
		powder.mint(msg.sender, getRandomUint(config.probabilities));
	}
}
