// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Solmate
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { Characters } from 'src/Characters.sol';
import { Chests } from 'src/Chests.sol';
import { Furnace } from 'src/Furnace.sol';
import { Olymp } from 'src/Olymp.sol';
import { OpenChests } from 'src/OpenChests.sol';
import { Powder } from 'src/Powder.sol';
import { Stones } from 'src/Stones.sol';
import { Training } from 'src/Training.sol';
import { MintableBEP20 } from 'src/lib/MintableBEP20.sol';

enum Roles {
	PowderMinter,
	StonesMinter,
	OlympMinter,
	CharactersMinter,
	OpenChestsMinter
}

struct TrainingConfig {
	Training training;
	Powder powder;
}

library AuthorityUtils {
	function deploy(address owner) public returns (RolesAuthority) {
		return new RolesAuthority(owner, Authority(address(0)));
	}

	function setupCharacters(RolesAuthority authority, Characters characters)
		public
	{
		authority.setRoleCapability(
			uint8(Roles.CharactersMinter),
			address(characters),
			Characters.mint.selector,
			true
		);
	}

	function setupChests(RolesAuthority authority, Chests chests) public {
		authority.setUserRole(address(chests), uint8(Roles.OpenChestsMinter), true);
	}

	function setupFurnace(RolesAuthority authority, Furnace furnace) public {
		authority.setUserRole(address(furnace), uint8(Roles.StonesMinter), true);
	}

	function setupOlymp(RolesAuthority authority, Olymp olymp) public {
		authority.setRoleCapability(
			uint8(Roles.OlympMinter),
			address(olymp),
			MintableBEP20.mint.selector,
			true
		);
	}

	function setupOpenChests(RolesAuthority authority, OpenChests openChests)
		public
	{
		authority.setRoleCapability(
			uint8(Roles.OpenChestsMinter),
			address(openChests),
			OpenChests.mint.selector,
			true
		);

		address addr = address(openChests);
		authority.setUserRole(addr, uint8(Roles.PowderMinter), true);
		authority.setUserRole(addr, uint8(Roles.OlympMinter), true);
		authority.setUserRole(addr, uint8(Roles.StonesMinter), true);
		authority.setUserRole(addr, uint8(Roles.CharactersMinter), true);
	}

	function setupPowder(RolesAuthority authority, Powder powder) public {
		authority.setRoleCapability(
			uint8(Roles.PowderMinter),
			address(powder),
			MintableBEP20.mint.selector,
			true
		);
	}

	function setupStones(RolesAuthority authority, Stones stones) public {
		authority.setRoleCapability(
			uint8(Roles.StonesMinter),
			address(stones),
			MintableBEP20.mint.selector,
			true
		);
	}

	function setupTraining(RolesAuthority authority, Training training) public {
		authority.setUserRole(address(training), uint8(Roles.PowderMinter), true);
	}
}
