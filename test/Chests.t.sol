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
import { MintableERC20 } from 'src/lib/MintableERC20.sol';
import { BurnableERC20 } from 'src/lib/BurnableERC20.sol';
import { Olymp } from 'src/Olymp.sol';
import { Powder } from 'src/Powder.sol';

// Mocks
import { CurrencyMock } from './mocks/CurrencyMock.sol';

// Data
import { CharactersData } from './data/CharactersData.sol';
import { ChestsData } from './data/ChestsData.sol';

contract ChestsTest is Test {
	CurrencyMock currency;
	Characters characters;
	Chests chests;

	Olymp olymp;
	Powder powder;
	Stones stones;

	Authority authority = Authority(address(0));
	address recipient = address(99);

	function setUp() public {
		// Tokens
		olymp = new Olymp('bOlymp', 'bOlymp', address(this), authority);
		powder = new Powder('Powder', 'POW', address(this), authority);
		stones = new Stones('Evolving Stones', 'EST', address(this), authority);

		// Dependencies
		currency = new CurrencyMock('USD', 'BUSD');
		characters = new Characters(
			'Characters',
			'CHAR',
			BurnableERC20(address(stones)),
			CharactersData.getLevelCosts()
		);

		// Chests
		chests = new Chests(
			currency,
			recipient,
			characters,
			MintableERC20(olymp),
			MintableERC20(powder),
			MintableERC20(stones),
			ChestsData.getChests(),
			ChestsData.getConfigs()
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

	function getChest(uint256 id) private view returns (Chest memory chest) {
		(uint16 minted, uint16 max, uint224 price) = chests.chests(id);
		chest = Chest(minted, max, price);
	}
}
