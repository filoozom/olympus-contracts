// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Custom
import { Characters, Rarities, Character } from 'src/Characters.sol';
import { EvolvingStones } from 'src/EvolvingStones.sol';

// Data
import { CharactersData } from './data/CharactersData.sol';
import { AuthorityData } from './data/AuthorityData.sol';

contract CharactersTest is Test {
	EvolvingStones stones;
	Characters characters;

	function setUp() public {
		stones = new EvolvingStones(
			'Evolving Stones',
			'EST',
			address(this),
			AuthorityData.getNull()
		);

		characters = new Characters(
			'Name',
			'Symbol',
			EvolvingStones(address(0)),
			CharactersData.getLevelCosts()
		);
	}

	function testCanMint() public {
		characters.mint(address(1), 3, Rarities.Gold);

		(
			uint256 id,
			string memory nickname,
			uint8 level,
			Rarities rarity
		) = characters.characters(0);

		assertEq(id, 3);
		assertEq(nickname, '');
		assertEq(level, 1);
		assertEq(uint8(rarity), uint8(Rarities.Gold));
	}

	function testCanMintAllRarities() public {
		characters.mint(address(1), 0, Rarities.Normal);
		characters.mint(address(1), 1, Rarities.Gold);
		characters.mint(address(1), 2, Rarities.Diamond);
	}

	function testCannotMintUnknownCharacter() public {
		vm.expectRevert('UNKNOWN_CHARACTER');
		characters.mint(address(1), 6, Rarities.Normal);
	}
}
