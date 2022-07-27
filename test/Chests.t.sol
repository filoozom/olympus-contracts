// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { Chests, Chest } from 'src/Chests.sol';
import { Characters, Rarities } from 'src/Characters.sol';
import { Stones } from 'src/Stones.sol';
import { MintableBEP20 } from 'src/lib/MintableBEP20.sol';
import { BurnableBEP20 } from 'src/lib/BurnableBEP20.sol';
import { Olymp } from 'src/Olymp.sol';
import { Powder } from 'src/Powder.sol';

// Mocks
import { ERC20Mock } from './mocks/ERC20Mock.sol';

// Data
import { CharactersData } from './data/CharactersData.sol';
import { ChestsData } from './data/ChestsData.sol';

contract ChestsTest is Test {
	ERC20Mock currency;
	Characters characters;
	Chests chests;

	Olymp olymp;
	Powder powder;
	Stones stones;

	Authority authority = Authority(address(0));
	address recipient = address(99);

	function getChest(uint256 id) private view returns (Chest memory chest) {
		(uint16 minted, uint16 max, uint224 price) = chests.chests(id);
		chest = Chest(minted, max, price);
	}

	function setUp() public {
		// Tokens
		olymp = new Olymp('bOlymp', 'bOlymp', address(this), authority);
		powder = new Powder('Powder', 'POW', address(this), authority);
		stones = new Stones('Evolving Stones', 'EST', address(this), authority);

		// Dependencies
		currency = new ERC20Mock('USD', 'BUSD');
		characters = new Characters(
			'Characters',
			'CHAR',
			BurnableBEP20(address(stones)),
			CharactersData.getLevelCosts()
		);

		// Chests
		chests = new Chests(
			currency,
			recipient,
			characters,
			MintableBEP20(olymp),
			MintableBEP20(powder),
			MintableBEP20(stones),
			ChestsData.getChests(),
			ChestsData.getConfigs()
		);

		// Set roles
		olymp.setOwner(address(chests));
		powder.setOwner(address(chests));
		stones.setOwner(address(chests));

		// We need at least 64 mined blocks for randomness
		vm.roll(64);
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
		chests.open(3);

		// Reused variables
		uint256 balance;

		// Check olymp balance
		balance = olymp.balanceOf(user);
		assertTrue(balance == 1600 || balance == 3200 || balance == 6400);

		// Check powder balance
		balance = powder.balanceOf(user);
		assertTrue(balance == 80 || balance == 160 || balance == 400);

		// Make sure only one character was minted
		assertEq(characters.ownerOf(0), user);
		vm.expectRevert('NOT_MINTED');
		characters.ownerOf(1);
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
				chests.open(chest);
			}
		}
	}
}
