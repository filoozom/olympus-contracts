// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Custom
import {RandomnessMock, Probability} from './mocks/RandomnessMock.sol';

contract RandomnessTest is Test {
	function setUp() public {}

	function testOutput(uint256) public {
		Probability[] memory probabilities = new Probability[](4);

		probabilities[0] = Probability(30, 20);
		probabilities[1] = Probability(40, 30);
		probabilities[2] = Probability(20, 50);
		probabilities[3] = Probability(10, 80);

		RandomnessMock random = new RandomnessMock(probabilities);
		uint16 number = random.getRandomNumber();

		assertTrue(
			number == 20 || number == 30 || number == 50 || number == 80
		);
	}

	function testAccuracy() public {
		Probability[] memory probabilities = new Probability[](4);
		uint16[] memory values = new uint16[](4);

		probabilities[0] = Probability(30, 0);
		probabilities[1] = Probability(40, 1);
		probabilities[2] = Probability(20, 2);
		probabilities[3] = Probability(10, 3);

		RandomnessMock random = new RandomnessMock(probabilities);

		for (uint256 i = 0; i < 10000; ) {
			unchecked {
				values[random.getRandomNumber()]++;
				i++;
			}
		}

		assertApproxEqAbs(values[0], 3000, 100);
		assertApproxEqAbs(values[1], 4000, 100);
		assertApproxEqAbs(values[2], 2000, 100);
		assertApproxEqAbs(values[3], 1000, 100);
	}
}
