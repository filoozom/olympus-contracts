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

	/*
	function createConfig(
		uint32 _duration,
		uint8[] memory _probabilities,
		uint16[] memory _results
	) private returns (Config memory config) {
		uint256 length = _probabilities.length;
		Probability[] memory probabilities = new Probability[](length);

		for (uint256 i = 0; i < length; ) {
			probabilities[i] = Probability({
				probability: _probabilities[i],
				result: _results[i]
			});

			unchecked {
				++i;
			}
		}

		return Config({duration: _duration, probabilities: probabilities});
	}
  */

	function setUp() public {
		/*
		Config[] memory configs = new Config[](3);

		uint8[] memory probabilities = new uint8[](4);
		probabilities[0] = 30;
		probabilities[1] = 40;
		probabilities[2] = 20;
		probabilities[3] = 10;

		uint16[] memory results = new uint16[](4);
		probabilities[0] = 20;
		probabilities[1] = 30;
		probabilities[2] = 50;
		probabilities[3] = 80;

		configs[0] = createConfig(86400, probabilities, results);


		characters = new Characters('Name', 'Symbol');
		training = new Training(characters, configs);
    */
		/*
    configs.push(Config({
      duration: 86400,
      probabilities
    }))
    */
	}

	function testTest() public {
		/*
		uint8[] memory probabilities = new uint8[](4);
		probabilities[0] = 30;
		probabilities[1] = 40;
		probabilities[2] = 20;
		probabilities[3] = 10;
    */
		//console.log(54);
		//console.log(abi.encode(probabilities));
	}
}
