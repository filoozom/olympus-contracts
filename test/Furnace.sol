// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Test.sol';

// Custom
import { Furnace } from 'src/Furnace.sol';
import { Powder } from 'src/Powder.sol';
import { Stones } from 'src/Stones.sol';
import { MintableBEP20 } from 'src/lib/MintableBEP20.sol';
import { BurnableBEP20 } from 'src/lib/BurnableBEP20.sol';

// Data
import { AuthorityData } from 'script/data/AuthorityData.sol';

contract FurnaceTest is Test {
	event Transfer(address indexed from, address indexed to, uint256 amount);
	event Forge(address indexed user, uint8 count, uint64 end);
	event Redeem(address indexed user, uint8 count);

	Furnace furnace;

	Powder powder;
	Stones stones;

	function setUp() public {
		// Tokens
		powder = new Powder(
			'Powder',
			'POW',
			address(this),
			AuthorityData.getNull()
		);
		stones = new Stones(
			'Evolving Stones',
			'EST',
			address(this),
			AuthorityData.getNull()
		);

		// Furnance
		furnace = new Furnace(
			BurnableBEP20(powder),
			MintableBEP20(stones),
			100,
			8 hours
		);

		// Set rights
		stones.setOwner(address(furnace));
	}

	function testCanForge() public {
		// Mint and approve tokens
		powder.mint(address(this), 300);
		powder.approve(address(furnace), 300);

		// Expect burn event of 300 powder
		uint256 snapshot = vm.snapshot();
		vm.expectEmit(true, true, true, true, address(powder));
		emit Transfer(address(this), address(0), 300);

		// Forge 3 stones
		furnace.forge(3);
		vm.revertTo(snapshot);

		// Expect forge event
		vm.expectEmit(true, true, true, true, address(furnace));
		emit Forge(address(this), 3, uint64(block.timestamp) + 8 hours);

		// Forge 3 stones
		furnace.forge(3);
	}

	function testCannotForgeWhileForging() public {
		// Mint and approve tokens
		powder.mint(address(this), 300);
		powder.approve(address(furnace), 300);

		// Forge 3 stones
		furnace.forge(3);

		// Try to forge stones again
		vm.expectRevert('NOT_DONE');
		furnace.forge(1);
	}

	function testCannotForgeWithoutEnoughPowder() public {
		vm.expectRevert(stdError.arithmeticError);
		furnace.forge(1);
	}

	function testCanRedeem() public {
		// Mint and approve tokens
		powder.mint(address(this), 300);
		powder.approve(address(furnace), 300);

		// Forge 3 stones
		furnace.forge(3);

		// Move 8 hours into the future
		vm.warp(block.timestamp + 8 hours);

		// Expect transfer event of 3 stones
		uint256 snapshot = vm.snapshot();
		vm.expectEmit(true, true, true, true, address(stones));
		emit Transfer(address(0), address(this), 3);

		// Redeem
		furnace.redeem();
		vm.revertTo(snapshot);

		// Expect forge event
		vm.expectEmit(true, true, true, true, address(furnace));
		emit Redeem(address(this), 3);

		// Redeem
		furnace.redeem();

		// Try to redeem a second time
		vm.expectRevert('NOT_FORGING');
		furnace.redeem();
	}

	function testCannotRedeemIfNotDone() public {
		// Mint and approve tokens
		powder.mint(address(this), 300);
		powder.approve(address(furnace), 300);

		// Forge 3 stones
		furnace.forge(3);

		// Move 8 hours minus one second into the future
		vm.warp(block.timestamp + 8 hours - 1);
		vm.expectRevert('NOT_DONE');
		furnace.redeem();
	}

	function testCannotRedeemIfNotForging() public {
		vm.expectRevert('NOT_FORGING');
		furnace.redeem();
	}

	function testCanForgeAfterRedeem() public {
		// Mint and approve tokens
		powder.mint(address(this), 400);
		powder.approve(address(furnace), 400);

		// Forge 3 stones
		furnace.forge(3);

		// Move 8 hours into the future
		vm.warp(block.timestamp + 8 hours);

		// Redeem
		furnace.redeem();

		// Try to forge again
		furnace.forge(1);
	}
}
