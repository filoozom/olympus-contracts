// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
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
import { AuthorityData } from 'script/data/AuthorityData.sol';
import { ChestsData } from 'script/data/ChestsData.sol';

// Lib
import { ToDynamicUtils } from 'script/lib/ToDynamicUtils.sol';

contract ChestsTest is Test {
	event ChestOpened(address indexed owner, uint256 indexed id);
	event OpenChestsMinted(address indexed to, uint256 indexed chestId);

	ERC20Mock currency;
	IOpenChests openChests;
	Chests chests;

	Authority authority = Authority(address(0));
	address recipient = address(99);
	uint256 endTimestamp = block.timestamp + 1 hours;

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
			address(this),
			AuthorityData.getNull(),
			currency,
			recipient,
			openChests,
			ChestsData.getChests(),
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

		// Mint 6 rare chests
		chests.mint(2, 6);

		// Check state
		assertEq(getChest(2).minted, 6);

		// Check balances
		uint256 price = 600e18;
		assertEq(currency.balanceOf(recipient), price);
		assertEq(currency.balanceOf(user), 1e64 - price);
		assertEq(chests.balanceOf(user, 2), 6);
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
		chests.mint(2, 6);
	}

	function testCanBuyAllChests() public {
		currency.mint(address(1), 330e18);
		vm.startPrank(address(1));

		// Mint and approve currency
		currency.approve(address(chests), 330e18);

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
		chests.mint(0, 1151);

		// Mint all chests and then try to mint one more
		chests.mint(0, 1150);
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.mint(0, 1);

		// Make sure that there are actually 1000 minted chests
		assertEq(getChest(0).minted, 1150);
	}

	function testCanBatchBuyChest() public {
		address user = address(1);

		// Prank EOA so we don't have to implement ERC1155TokenReceiver
		currency.mint(user, 1e64);
		vm.startPrank(user);

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint 6 rare chests
		chests.batchMint(
			ToDynamicUtils.toDynamic([uint256(0), 2]),
			ToDynamicUtils.toDynamic([uint256(8), 6])
		);

		// Check state
		assertEq(getChest(0).minted, 8);
		assertEq(getChest(2).minted, 6);

		// Check balances
		uint256 price = 240e18 + 600e18;
		assertEq(currency.balanceOf(recipient), price);
		assertEq(currency.balanceOf(user), 1e64 - price);
		assertEq(chests.balanceOf(user, 0), 8);
		assertEq(chests.balanceOf(user, 2), 6);
	}

	function testCanBatchBuySameChest() public {
		address user = address(1);

		// Prank EOA so we don't have to implement ERC1155TokenReceiver
		currency.mint(user, 1e64);
		vm.startPrank(user);

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Mint 6 rare chests
		chests.batchMint(
			ToDynamicUtils.toDynamic([uint256(0), 0, 0]),
			ToDynamicUtils.toDynamic([uint256(8), 6, 6])
		);

		// Check state
		assertEq(getChest(0).minted, 20);

		// Check balances
		uint256 price = 600e18;
		assertEq(currency.balanceOf(recipient), price);
		assertEq(currency.balanceOf(user), 1e64 - price);
		assertEq(chests.balanceOf(user, 0), 20);
	}

	function testCannotBatchBuyMoreChestsThanAvailable() public {
		currency.mint(address(1), 1e64);
		vm.startPrank(address(1));

		// Mint and approve currency
		currency.approve(address(chests), 1e64);

		// Store ids and amounts because `vm.expectRevert` doesn't
		// work with inlined `ToDynamicUtils.toDynamic`
		uint256[] memory ids;
		uint256[] memory amounts;

		// Mint too many chests
		ids = ToDynamicUtils.toDynamic([uint256(0)]);
		amounts = ToDynamicUtils.toDynamic([uint256(1151)]);
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.batchMint(ids, amounts);

		// Mint all chests and then try to mint one more
		ids = ToDynamicUtils.toDynamic([uint256(0)]);
		amounts = ToDynamicUtils.toDynamic([uint256(1150)]);
		chests.batchMint(ids, amounts);

		// Mint one more chest than available
		ids = ToDynamicUtils.toDynamic([uint256(0)]);
		amounts = ToDynamicUtils.toDynamic([uint256(1)]);
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.batchMint(ids, amounts);

		// Make sure that there are actually 1000 minted chests
		assertEq(getChest(0).minted, 1150);

		// Mint the same chest multiple times in one batch
		ids = ToDynamicUtils.toDynamic([uint256(1), 1, 1, 1]);
		amounts = ToDynamicUtils.toDynamic([uint256(400), 200, 25, 26]);
		vm.expectRevert('NOT_ENOUGH_LEFT');
		chests.batchMint(ids, amounts);
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

	function testUri() public {
		assertEq(chests.uri(0), 'http://example.com/chests/{id}.json');
		assertEq(chests.uri(1), 'http://example.com/chests/{id}.json');
		assertEq(chests.uri(2), 'http://example.com/chests/{id}.json');
		assertEq(chests.uri(3), 'http://example.com/chests/{id}.json');
	}

	function testCanBatchMintForFree() public {
		address to = address(465);

		// Mint
		chests.batchMintFree(
			to,
			ToDynamicUtils.toDynamic([uint256(1)]),
			ToDynamicUtils.toDynamic([uint256(10)])
		);

		// Check state
		assertEq(getChest(1).minted, 10);

		// Check balances
		assertEq(currency.balanceOf(recipient), 0);
		assertEq(chests.balanceOf(to, 1), 10);
	}

	function testCannotBatchMintForFreeIfNotAuthorized() public {
		address to = address(465);
		vm.prank(to);

		// Mint
		vm.expectRevert('UNAUTHORIZED');
		chests.batchMintFree(
			to,
			ToDynamicUtils.toDynamic([uint256(1)]),
			ToDynamicUtils.toDynamic([uint256(10)])
		);
	}

	function testCanCreateNewChests() public {
		Chest[] memory newChests = new Chest[](2);
		newChests[0] = Chest(0, 123, 1234e18);
		newChests[1] = Chest(0, 234, 2345e18);

		chests.setChests(newChests);

		assertEq(getChest(4).minted, 0);
		assertEq(getChest(4).max, 123);
		assertEq(getChest(4).price, 1234e18);

		assertEq(getChest(5).minted, 0);
		assertEq(getChest(5).max, 234);
		assertEq(getChest(5).price, 2345e18);
	}
}
