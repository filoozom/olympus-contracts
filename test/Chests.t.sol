// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';

// Custom
import { Chests, Chest } from 'src/Chests.sol';
import { Characters } from 'src/Characters.sol';
import { EvolvingStones } from 'src/EvolvingStones.sol';

// Mocks
import { CurrencyMock } from './mocks/CurrencyMock.sol';

// Data
import { ChestsData } from './data/ChestsData.sol';

contract ChestsTest is Test {
	ERC20 currency;
	Characters characters;
	Chests chests;

	function setUp() public {
		currency = new CurrencyMock('USD', 'BUSD');
		characters = new Characters(
			'Name',
			'Symbol',
			EvolvingStones(address(0)),
			new uint8[](0)
		);
		chests = new Chests(
			currency,
			address(1),
			characters,
			new Chest[](0),
			ChestsData.getConfigs()
		);
	}
}
