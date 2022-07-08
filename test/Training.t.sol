// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Custom
import { Characters } from 'src/Characters.sol';
import { Training } from 'src/Training.sol';
import { Probabilities } from 'src/lib/Randomness.sol';
import { EvolvingStones } from 'src/EvolvingStones.sol';

// Data
import { TrainingData } from './data/TrainingData.sol';

contract TrainingTest is Test {
	Characters characters;
	Training training;

	function setUp() public {
		characters = new Characters(
			'Name',
			'Symbol',
			EvolvingStones(address(0)),
			new uint8[](0)
		);
		training = new Training(
			characters,
			TrainingData.getDurations(),
			TrainingData.getProbabilities()
		);
	}
}
