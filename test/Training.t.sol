// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Custom
import {Characters} from 'src/Characters.sol';
import {Training} from 'src/Training.sol';
import {Probabilities} from 'src/lib/Randomness.sol';

contract TrainingTest is Test {
	Characters characters;
	Training training;

	function setUp() public {
		characters = new Characters('Name', 'Symbol');
		training = new Training(characters, getDurations(), getProbabilities());
	}

	// Data
	function getDurations() public pure returns (uint32[] memory durations) {
		durations = new uint32[](3);
		durations[0] = 86400;
		durations[1] = 259200;
		durations[2] = 604800;
	}

	function getProbabilities()
		public
		pure
		returns (Probabilities[] memory probabilities)
	{
		probabilities = new Probabilities[](3);
		probabilities[0] = getOneDayProbabilities();
		probabilities[1] = getThreeDaysProbabilities();
		probabilities[2] = getSevenDaysProbabilities();
	}

	function getOneDayProbabilities()
		public
		pure
		returns (Probabilities memory probabilities)
	{
		uint16[] memory results = new uint16[](4);
		results[0] = 80;
		results[1] = 50;
		results[2] = 20;
		results[3] = 30;

		probabilities = Probabilities({
			sum: 100,
			shares: getShares(),
			results: results
		});
	}

	function getThreeDaysProbabilities()
		public
		pure
		returns (Probabilities memory probabilities)
	{
		uint16[] memory results = new uint16[](4);
		results[0] = 220;
		results[1] = 130;
		results[2] = 75;
		results[3] = 45;

		probabilities = Probabilities({
			sum: 100,
			shares: getShares(),
			results: results
		});
	}

	function getSevenDaysProbabilities()
		public
		pure
		returns (Probabilities memory probabilities)
	{
		uint16[] memory results = new uint16[](4);
		results[0] = 360;
		results[1] = 210;
		results[2] = 115;
		results[3] = 65;

		probabilities = Probabilities({
			sum: 100,
			shares: getShares(),
			results: results
		});
	}

	function getShares() public pure returns (uint8[] memory shares) {
		shares = new uint8[](4);
		shares[0] = 10;
		shares[1] = 20;
		shares[2] = 30;
		shares[3] = 40;
	}
}
