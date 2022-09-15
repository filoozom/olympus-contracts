// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Script.sol';

// Solmate
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';

// Lib
import { AuthorityUtils } from './lib/AuthorityUtils.sol';

// Data
import { TrainingData } from './data/TrainingData.sol';

// Contracts
import { Characters } from 'src/Characters.sol';
import { Powder } from 'src/Powder.sol';
import { Training } from 'src/Training.sol';

contract DeployTrainingScript is Script, AuthorityUtils {
	Characters characters =
		Characters(0x91aF80F5AC26727D97272F6244143439F3C2C2aa);
	Powder powder = Powder(0xe5dbe4813C3F3F9702316FEB71479Bc6c83D99C0);

	function setUp() public {
		authority = RolesAuthority(0x37D98eDb9C93c8E70ec737E9c51d16C908fBb33b);
		owner = msg.sender;
	}

	function run() public {
		vm.startBroadcast();

		setupTraining(deployTraining());

		vm.stopBroadcast();
	}

	function deployTraining() private returns (Training) {
		return
			new Training(
				characters,
				powder,
				TrainingData.getDurations(),
				TrainingData.getProbabilities()
			);
	}
}
