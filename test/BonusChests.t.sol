// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Test.sol';

// Solmate
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { BonusChests, Chest } from 'src/BonusChests.sol';
import { IOpenChests } from 'src/interfaces/IOpenChests.sol';

// Mocks
import { ERC20Mock } from './mocks/ERC20Mock.sol';
import { OpenChestsMock } from './mocks/OpenChestsMock.sol';

// Data
import { AuthorityData } from 'script/data/AuthorityData.sol';
import { BonusChestsData } from 'script/data/BonusChestsData.sol';

// Lib
import { ToDynamicUtils } from 'script/lib/ToDynamicUtils.sol';

contract BonusChestsTest is Test {
	event ChestOpened(address indexed owner, uint256 indexed id);
	event OpenChestsMinted(address indexed to, uint256 indexed chestId);

	ERC20Mock currency;
	IOpenChests openChests;
	BonusChests chests;

	Authority authority = Authority(address(0));
	address recipient = address(99);
	uint256 endTimestamp = block.timestamp + 1 hours;

	function getChest() private view returns (Chest memory chest) {
		(uint16 minted, uint16 max, uint224 price) = chests.chest();
		chest = Chest(minted, max, price);
	}

	function setUp() public {
		// Dependencies
		currency = new ERC20Mock('USD', 'BUSD');
		openChests = new OpenChestsMock();

		// Chests
		chests = new BonusChests(
			currency,
			recipient,
			openChests,
			BonusChestsData.getChest(),
			'http://example.com/chests/{id}.json',
			endTimestamp
		);
	}

	function testCanBuyChest() public {
		address user = address(1);

		// Prank EOA so we don't have to implement ERC1155TokenReceiver
		currency.mint(user, 1e64);
		vm.startPrank(user);

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint 6 chests
		chests.mint(6);

		// Check state
		assertEq(getChest().minted, 6);

		// Check balances
		uint256 price = 840e18;
		assertEq(currency.balanceOf(recipient), price);
		assertEq(currency.balanceOf(user), 1e64 - price);
		assertEq(chests.balanceOf(user, 4), 6);
	}

	function testCannotBuyChestAfterEndDate() public {
		address user = address(1);

		// Prank EOA so we don't have to implement ERC1155TokenReceiver
		currency.mint(user, 1e64);
		vm.startPrank(user);

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint 1 rare chest
		vm.warp(endTimestamp);
		vm.expectRevert('MINTING_OVER');
		chests.mint(6);
	}

	function testCannotBuyMoreChestsThanAvailable() public {
		currency.mint(address(1), 1e64);
		vm.startPrank(address(1));

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint too many chests
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.mint(351);

		// Mint all chests and then try to mint one more
		chests.mint(350);
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.mint(1);

		// Make sure that there are actually 1000 minted chests
		assertEq(getChest().minted, 350);
	}

	function testCanOpenChest() public {
		address user = address(1);

		// Mint four chests
		currency.mint(user, 1e64);
		vm.startPrank(user);
		currency.approve(address(chests), 1e64);
		chests.mint(4);

		// Open one chest
		uint256 snapshot = vm.snapshot();
		vm.expectEmit(true, true, true, true);
		emit ChestOpened(user, 4);
		chests.open(4);

		vm.revertTo(snapshot);
		vm.expectEmit(true, true, true, true);
		emit OpenChestsMinted(user, 5);
		chests.open(5);
	}

	function testCanOpenAllChests() public {
		address user = address(1);

		// Mint four chests
		currency.mint(user, 1e64);
		vm.startPrank(user);
		currency.approve(address(chests), 1e64);

		// Mint 5 of each chest
		chests.mint(8);

		// Open all chests
		for (uint8 i = 0; i < 8; i++) {
			uint256 snapshot = vm.snapshot();
			vm.expectEmit(true, true, true, true);
			emit ChestOpened(user, 4);
			chests.open(4);

			vm.revertTo(snapshot);
			vm.expectEmit(true, true, true, true);
			emit OpenChestsMinted(user, 4);
			chests.open(4);
		}

		// Open all bonus chests
		for (uint8 i = 0; i < 2; i++) {
			uint256 snapshot = vm.snapshot();
			vm.expectEmit(true, true, true, true);
			emit ChestOpened(user, 5);
			chests.open(5);

			vm.revertTo(snapshot);
			vm.expectEmit(true, true, true, true);
			emit OpenChestsMinted(user, 5);
			chests.open(5);
		}
	}

	function testUri() public {
		assertEq(chests.uri(0), 'http://example.com/chests/{id}.json');
		assertEq(chests.uri(1), 'http://example.com/chests/{id}.json');
		assertEq(chests.uri(2), 'http://example.com/chests/{id}.json');
		assertEq(chests.uri(3), 'http://example.com/chests/{id}.json');
	}

	function testUserReceivesBonusBoxes() public {
		address user = address(1);

		// Prank EOA so we don't have to implement ERC1155TokenReceiver
		currency.mint(user, 1e64);
		vm.startPrank(user);

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint 2 chests
		chests.mint(2);
		assertEq(chests.balanceOf(user, 4), 2);
		assertEq(chests.balanceOf(user, 5), 0);

		// Mint 3 chests
		chests.mint(3);
		assertEq(chests.balanceOf(user, 4), 5);
		assertEq(chests.balanceOf(user, 5), 1);

		// Mint 5 chests
		chests.mint(5);
		assertEq(chests.balanceOf(user, 4), 10);
		assertEq(chests.balanceOf(user, 5), 2);

		// Mint 10 chests
		chests.mint(10);
		assertEq(chests.balanceOf(user, 4), 20);
		assertEq(chests.balanceOf(user, 5), 5);
	}
}
