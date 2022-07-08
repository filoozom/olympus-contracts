// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Custom
import { RandomnessMock, Probabilities } from './mocks/RandomnessMock.sol';

contract RandomnessTest is Test {
	function setUp() public {}

	function testOutput(uint256) public {
		Probabilities memory probabilities = Probabilities({
			sum: getSum(),
			shares: getShares(),
			results: getResults()
		});

		RandomnessMock random = new RandomnessMock(probabilities);
		uint16 number = random.getRandomNumber();

		assertTrue(
			number == 20 || number == 30 || number == 50 || number == 80
		);
	}

	function testAccuracy() public {
		Probabilities memory probabilities = Probabilities({
			sum: getSum(),
			shares: getShares(),
			results: getBasicResults()
		});

		RandomnessMock random = new RandomnessMock(probabilities);
		uint16[] memory values = new uint16[](4);

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

	// Data
	function getSum() public pure returns (uint16 sum) {
		uint8[] memory shares = getShares();
		uint256 length = shares.length;

		for (uint256 i = 0; i < length; i++) {
			sum += shares[i];
		}
	}

	function getShares() public pure returns (uint8[] memory shares) {
		shares = new uint8[](4);
		shares[0] = 10;
		shares[1] = 20;
		shares[2] = 30;
		shares[3] = 40;
	}

	function getResults() public pure returns (uint16[] memory results) {
		results = new uint16[](4);
		results[0] = 80;
		results[1] = 50;
		results[2] = 20;
		results[3] = 30;
	}

	function getBasicResults() public pure returns (uint16[] memory results) {
		results = new uint16[](4);
		results[0] = 3;
		results[1] = 2;
		results[2] = 0;
		results[3] = 1;
	}
}
