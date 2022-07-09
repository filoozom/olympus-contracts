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
	event Minted(address indexed owner, uint256 indexed id, Rarities rarity);
	event SetNickname(uint256 indexed id, string name);
	event Evolve(uint256 indexed id, uint256 newLevel);

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
			EvolvingStones(address(stones)),
			CharactersData.getLevelCosts()
		);
	}

	function testCanMint() public {
		// Expect event
		vm.expectEmit(true, true, true, true);
		emit Minted(address(1), 3, Rarities.Gold);

		// Mint
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

	function testCanEvolve() public {
		// Mint stones and approve
		stones.mint(address(this), 100);
		stones.approve(address(characters), 100);

		// Mint a character
		characters.mint(address(this), 0, Rarities.Normal);

		// Expect event
		vm.expectEmit(true, true, true, false);
		emit Evolve(0, 2);

		// Evolve
		characters.evolve(0);
	}

	function testRequiresRightAmountOfStones() public {
		characters.mint(address(this), 0, Rarities.Normal);

		// Test with 0 stones
		vm.expectRevert(stdError.arithmeticError);
		characters.evolve(0);

		// Test with 3 stones
		stones.mint(address(this), 3);
		stones.approve(address(characters), 3);
		vm.expectRevert(stdError.arithmeticError);
		characters.evolve(0);

		// Test with 4 stones
		stones.mint(address(this), 1);
		stones.approve(address(characters), 4);
		characters.evolve(0);
	}

	function testCanEvolveNormalToMaxLevel() public {
		// Mint stones and approve
		stones.mint(address(this), 100);
		stones.approve(address(characters), 100);

		// Mint a character
		characters.mint(address(this), 0, Rarities.Normal);

		// Evolve to max level
		characters.evolve(0);
		characters.evolve(0);
		characters.evolve(0);

		// Try one level too far
		vm.expectRevert('ALREADY_MAX_LEVEL');
		characters.evolve(0);
	}

	function testCanEvolveGoldToMaxLevel() public {
		// Mint stones and approve
		stones.mint(address(this), 100);
		stones.approve(address(characters), 100);

		// Mint a character
		characters.mint(address(this), 0, Rarities.Gold);

		// Evolve to max level
		characters.evolve(0);
		characters.evolve(0);
		characters.evolve(0);
		characters.evolve(0);

		// Try one level too far
		vm.expectRevert('ALREADY_MAX_LEVEL');
		characters.evolve(0);
	}

	function testCanEvolveDiamondToMaxLevel() public {
		// Mint stones and approve
		stones.mint(address(this), 100);
		stones.approve(address(characters), 100);

		// Mint a character
		characters.mint(address(this), 0, Rarities.Diamond);

		// Evolve to max level
		characters.evolve(0);
		characters.evolve(0);
		characters.evolve(0);
		characters.evolve(0);
		characters.evolve(0);

		// Try one level too far
		vm.expectRevert('ALREADY_MAX_LEVEL');
		characters.evolve(0);
	}

	function testGetMaxLevel() public {
		characters.mint(address(1), 0, Rarities.Diamond);
		characters.mint(address(1), 1, Rarities.Normal);
		characters.mint(address(1), 2, Rarities.Gold);
		characters.mint(address(1), 3, Rarities.Diamond);

		assertEq(characters.getMaxLevel(0), 6);
		assertEq(characters.getMaxLevel(1), 4);
		assertEq(characters.getMaxLevel(2), 5);
		assertEq(characters.getMaxLevel(3), 6);

		vm.expectRevert(stdError.indexOOBError);
		characters.getMaxLevel(4);
	}

	function testSetNickname() public {
		// Mint a character
		characters.mint(address(this), 0, Rarities.Diamond);

		// Expect event
		vm.expectEmit(true, true, true, false);
		emit SetNickname(0, 'filoozom');

		// Change the character's nickname
		characters.setNickname(0, 'filoozom');
	}

	function testCannotSetNicknameIfNotOwner() public {
		// Mint a character
		characters.mint(address(1), 0, Rarities.Diamond);

		// Try to set the nickname
		vm.prank(address(2));
		vm.expectRevert('UNAUTHORIZED');
		characters.setNickname(0, 'filoozom');
	}

	function testCannotSetNicknameOfUnknownCharacter() public {
		vm.expectRevert('UNAUTHORIZED');
		characters.setNickname(0, 'filoozom');
	}
}
