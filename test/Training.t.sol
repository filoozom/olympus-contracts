// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Custom
import {Characters} from 'src/Characters.sol';
import {Training, Config} from 'src/Training.sol';
import {Probability} from 'src/lib/Randomness.sol';

contract TrainingTest is Test {
	Characters characters;
	Training training;

	function setUp() public {
		characters = new Characters('Name', 'Symbol');
		training = new Training(characters, getDurations(), getProbabilities());
	}

	// Data
	function getDurations() public view returns (uint32[] memory durations) {
		durations = new uint32[](3);
		durations[0] = 86400;
		durations[1] = 259200;
		durations[2] = 604800;
	}

	function getProbabilities()
		public
		view
		returns (Probability[][] memory probabilities)
	{
		probabilities = new Probability[][](3);
		probabilities[0] = getOneDayProbabilities();
		probabilities[1] = getThreeDaysProbabilities();
		probabilities[2] = getSevenDaysProbabilities();
	}

	function getOneDayProbabilities()
		public
		view
		returns (Probability[] memory probabilities)
	{
		probabilities = new Probability[](4);
		probabilities[0] = Probability(30, 20);
		probabilities[1] = Probability(40, 30);
		probabilities[2] = Probability(20, 50);
		probabilities[3] = Probability(10, 80);
	}

	function getThreeDaysProbabilities()
		public
		view
		returns (Probability[] memory probabilities)
	{
		probabilities = new Probability[](4);
		probabilities[0] = Probability(30, 45);
		probabilities[1] = Probability(40, 75);
		probabilities[2] = Probability(20, 130);
		probabilities[3] = Probability(10, 220);
	}

	function getSevenDaysProbabilities()
		public
		view
		returns (Probability[] memory probabilities)
	{
		probabilities = new Probability[](4);
		probabilities[0] = Probability(30, 65);
		probabilities[1] = Probability(40, 115);
		probabilities[2] = Probability(20, 210);
		probabilities[3] = Probability(10, 360);
	}
}
