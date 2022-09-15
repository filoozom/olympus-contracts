// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Test.sol';

// Custom
import { Characters, Rarities } from 'src/Characters.sol';
import { Training, Durations } from 'src/Training.sol';
import { Stones } from 'src/Stones.sol';
import { Powder } from 'src/Powder.sol';

// Data
import { TrainingData } from 'script/data/TrainingData.sol';
import { AuthorityData } from 'script/data/AuthorityData.sol';

contract TrainingTest is Test {
	event Transfer(address indexed from, address indexed to, uint256 amount);
	event TrainStart(uint256 indexed id, Durations time, uint64 end);
	event TrainEnd(uint256 indexed id, uint256 minted);

	Characters characters;
	Powder powder;
	Training training;

	function setUp() public {
		characters = new Characters(
			'Name',
			'Symbol',
			address(this),
			AuthorityData.getNull(),
			Stones(address(0)),
			new uint8[](0)
		);
		powder = new Powder(
			'Powder',
			'PWDR',
			address(this),
			AuthorityData.getNull()
		);
		training = new Training(
			characters,
			powder,
			TrainingData.getDurations(),
			TrainingData.getProbabilities()
		);

		// We need at least 64 mined blocks for randomness
		vm.roll(64);
	}

	function testCanTrain() public {
		characters.mint(address(this), 0, Rarities.Normal);

		vm.expectEmit(true, true, true, true, address(training));
		emit TrainStart(0, Durations.ThreeDays, uint64(block.timestamp + 3 days));
		training.train(0, Durations.ThreeDays);

		(uint256 end, Durations time) = training.sessions(0);
		assertEq(end, block.timestamp + 259200);
		assertEq(uint8(time), 1);
	}

	function testCanTrainAllDurations() public {
		// Mint 3 characters
		characters.mint(address(this), 0, Rarities.Normal);
		characters.mint(address(this), 0, Rarities.Normal);
		characters.mint(address(this), 0, Rarities.Normal);

		// Test training durations
		training.train(0, Durations.OneDay);
		training.train(1, Durations.ThreeDays);
		training.train(2, Durations.SevenDays);
	}

	function testCannotTrainWhileTraining() public {
		characters.mint(address(this), 0, Rarities.Normal);
		training.train(0, Durations.OneDay);

		vm.expectRevert('ALREADY_TRAINING');
		training.train(0, Durations.OneDay);
	}

	function testCannotTrainUnownedCharacter() public {
		characters.mint(address(1), 0, Rarities.Normal);

		vm.expectRevert('UNAUTHORIZED');
		training.train(0, Durations.OneDay);
	}

	function testCannotTrainWithUnknownDuration() public {
		characters.mint(address(this), 0, Rarities.Normal);
		(bool success, ) = address(training).call(
			abi.encodeWithSignature('train(uint256,uint8)', 0, 3)
		);
		assertFalse(success);
	}

	function testCanEndTraining() public {
		characters.mint(address(this), 0, Rarities.Normal);
		training.train(0, Durations.OneDay);

		// Give the training contract rights to mint powder
		powder.setOwner(address(training));

		// Warp to one day later
		vm.warp(block.timestamp + 86400);

		// Check that a TrainEnd event is emitted
		vm.recordLogs();
		uint256 snapshot = vm.snapshot();
		vm.expectEmit(true, true, true, false, address(training));
		emit TrainEnd(0, 0);
		vm.recordLogs();
		training.endTrain(0);
		Vm.Log[] memory logs = vm.getRecordedLogs();

		// Get minted amount from logs
		uint64 minted;
		for (uint256 i = 0; i < logs.length; i++) {
			if (logs[i].topics[0] == TrainEnd.selector) {
				minted = abi.decode(logs[i].data, (uint64));
				break;
			}
		}

		// Check that powder was minted
		vm.revertTo(snapshot);
		snapshot = vm.snapshot();
		vm.expectEmit(true, true, true, true, address(powder));
		emit Transfer(address(0), address(this), minted);
		training.endTrain(0);

		// Make sure that the minted amount is accurate
		assertTrue(minted == 20 || minted == 30 || minted == 50 || minted == 80);
	}

	function testCannotEndTrainingBeforeEarly() public {
		characters.mint(address(this), 0, Rarities.Normal);
		training.train(0, Durations.OneDay);

		vm.warp(block.timestamp + 86399);
		vm.expectRevert('NOT_DONE');
		training.endTrain(0);
	}

	function testCannotEndTrainIfNotOwner() public {
		characters.mint(address(this), 0, Rarities.Normal);
		training.train(0, Durations.OneDay);

		// Wrap to one day later
		vm.warp(block.timestamp + 86400);
		vm.prank(address(1));
		vm.expectRevert('UNAUTHORIZED');
		training.endTrain(0);
	}

	function testCanTrainAfterTrainEnd() public {
		characters.mint(address(this), 0, Rarities.Normal);
		training.train(0, Durations.OneDay);

		// Give the training contract rights to mint powder
		powder.setOwner(address(training));

		// Warp to one day later
		vm.warp(block.timestamp + 86400);
		training.endTrain(0);

		// Try to train again (check if state was reset)
		training.train(0, Durations.SevenDays);
	}

	function testCannotEndTrainWhileNotTraining() public {
		characters.mint(address(this), 0, Rarities.Normal);

		// Give the training contract rights to mint powder
		powder.setOwner(address(training));

		// Warp to one day later
		vm.warp(block.timestamp + 86400);
		vm.expectRevert('NOT_TRAINING');
		training.endTrain(0);
	}
}
