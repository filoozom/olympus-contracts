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
import { EvolvingStones } from 'src/EvolvingStones.sol';
import { MintableERC20 } from 'src/lib/MintableERC20.sol';
import { BurnableERC20 } from 'src/lib/BurnableERC20.sol';
import { Olymp } from 'src/Olymp.sol';
import { Powder } from 'src/Powder.sol';

// Mocks
import { CurrencyMock } from './mocks/CurrencyMock.sol';

// Data
import { ChestsData } from './data/ChestsData.sol';

contract ChestsTest is Test {
	ERC20 currency;
	Characters characters;
	Chests chests;

	Olymp olymp;
	Powder powder;
	EvolvingStones evolvingStones;

	Authority authority = Authority(address(0));

	function setUp() public {
		// Tokens
		olymp = new Olymp('bOlymp', 'bOlymp', msg.sender, authority);
		powder = new Powder('Powder', 'POW', msg.sender, authority);
		evolvingStones = new EvolvingStones(
			'Evolving Stones',
			'EST',
			msg.sender,
			authority
		);

		// Dependencies
		currency = new CurrencyMock('USD', 'BUSD');
		characters = new Characters(
			'Name',
			'Symbol',
			BurnableERC20(evolvingStones),
			new uint8[](0)
		);

		// Chests
		chests = new Chests(
			currency,
			address(1),
			characters,
			MintableERC20(olymp),
			MintableERC20(powder),
			MintableERC20(evolvingStones),
			ChestsData.getChests(),
			ChestsData.getConfigs()
		);
	}
}
