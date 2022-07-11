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
	ERC20 currency;
	Characters characters;
	Chests chests;

	Olymp olymp;
	Powder powder;
	Stones stones;

	Authority authority = Authority(address(0));

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
			address(1),
			characters,
			MintableERC20(olymp),
			MintableERC20(powder),
			MintableERC20(stones),
			ChestsData.getChests(),
			ChestsData.getConfigs()
		);
	}
}
