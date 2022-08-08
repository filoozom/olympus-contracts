// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Solmate
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { Chests, Chest } from 'src/Chests.sol';
import { IOpenChests } from 'src/interfaces/IOpenChests.sol';

// Mocks
import { ERC20Mock } from './mocks/ERC20Mock.sol';
import { OpenChestsMock } from './mocks/OpenChestsMock.sol';

// Data
import { ChestsData } from './data/ChestsData.sol';

contract ChestsTest is Test {
	event ChestOpened(address indexed owner, uint256 indexed id);
	event OpenChestsMinted(address indexed to, uint256 indexed chestId);

	ERC20Mock currency;
	IOpenChests openChests;
	Chests chests;

	Authority authority = Authority(address(0));
	address recipient = address(99);

	function getChest(uint256 id) private view returns (Chest memory chest) {
		(uint16 minted, uint16 max, uint224 price) = chests.chests(id);
		chest = Chest(minted, max, price);
	}

	function setUp() public {
		// Dependencies
		currency = new ERC20Mock('USD', 'BUSD');
		openChests = new OpenChestsMock();

		// Chests
		chests = new Chests(
			currency,
			recipient,
			openChests,
			ChestsData.getChests()
		);
	}

	function testCanBuyChest() public {
		address user = address(1);

		// Prank EOA so we don't have to implement ERC1155TokenReceiver
		currency.mint(user, 1e64);
		vm.startPrank(user);

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint 6 rare chests
		chests.mint(2, 6);

		// Check state
		assertEq(getChest(2).minted, 6);

		// Check balances
		assertEq(currency.balanceOf(recipient), 960e18);
		assertEq(currency.balanceOf(user), 1e64 - 960e18);
		assertEq(chests.balanceOf(user, 2), 6);
	}

	function testCanBuyAllChests() public {
		currency.mint(address(1), 580e18);
		vm.startPrank(address(1));

		// Mint and approve currency
		currency.approve(address(chests), 580e18);

		// Mint one of each chest
		chests.mint(0, 1);
		chests.mint(1, 1);
		chests.mint(2, 1);
		chests.mint(3, 1);

		// Check that all the currency was used
		assertEq(currency.balanceOf(address(this)), 0);

		// Check chest data
		assertEq(getChest(0).minted, 1);
		assertEq(getChest(1).minted, 1);
		assertEq(getChest(2).minted, 1);
		assertEq(getChest(3).minted, 1);
	}

	function testCannotBuyMoreChestsThanAvailable() public {
		currency.mint(address(1), 1e64);
		vm.startPrank(address(1));

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint too many chests
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.mint(0, 1001);

		// Mint all chests and then try to mint one more
		chests.mint(0, 1000);
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.mint(0, 1);

		// Make sure that there are actually 1000 minted chests
		assertEq(getChest(0).minted, 1000);
	}

	function testCanOpenChest() public {
		address user = address(1);

		// Mint four chests
		currency.mint(user, 1e64);
		vm.startPrank(user);
		currency.approve(address(chests), 1e64);
		chests.mint(3, 4);

		// Open one chest
		uint256 snapshot = vm.snapshot();
		vm.expectEmit(true, true, true, true);
		emit ChestOpened(user, 3);
		chests.open(3);

		vm.revertTo(snapshot);
		vm.expectEmit(true, true, true, true);
		emit OpenChestsMinted(user, 3);
		chests.open(3);
	}

	function testCanOpenAllChests() public {
		address user = address(1);

		// Mint four chests
		currency.mint(user, 1e64);
		vm.startPrank(user);
		currency.approve(address(chests), 1e64);

		// Mint 5 of each chest
		chests.mint(0, 5);
		chests.mint(1, 5);
		chests.mint(2, 5);
		chests.mint(3, 5);

		// Open all chests
		for (uint8 chest = 0; chest < 4; chest++) {
			for (uint8 i = 0; i < 5; i++) {
				uint256 snapshot = vm.snapshot();
				vm.expectEmit(true, true, true, true);
				emit ChestOpened(user, chest);
				chests.open(chest);

				vm.revertTo(snapshot);
				vm.expectEmit(true, true, true, true);
				emit OpenChestsMinted(user, chest);
				chests.open(chest);
			}
		}
	}
}
