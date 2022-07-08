// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { Characters } from 'src/Characters.sol';
import { Chests } from 'src/Characters.sol';
import { EvolvingStones } from 'src/EvolvingStones.sol';
import { Olymp } from 'src/Olymp.sol';
import { Powder } from 'src/Powder.sol';
import { Training } from 'src/Training.sol';

enum Roles {
	PowderMinter,
	EvolvingStonesMinter,
	OlympMinter,
	CharactersMinter
}

struct TrainingConfig {
	Training training;
	Powder powder;
}

library AuthorityLib {
	function deploy(address owner) public returns (RolesAuthority) {
		return new RolesAuthority(owner, Authority(address(0)));
	}

	function setupCharacters(Authority authority, Characters characters) {
		authority.setRoleCapability(
			Roles.CharactersMinter,
			characters,
			Characters.mint.selector,
			true
		);
	}

	function setupChests(Authority authority, Chests chests) {
		authority.setUserRole(chests, Roles.PowderMinter, true);
		authority.setUserRole(chests, Roles.OlympMinter, true);
		authority.setUserRole(chests, Roles.EvolvingStonesMinter, true);
		authority.setUserRole(chests, Roles.CharactersMinter, true);
	}

	function setupEvolvingStones(
		Authority authority,
		EvolvingStones evolvingStones
	) {
		authority.setRoleCapability(
			Roles.EvolvingStonesMinter,
			evolvingStones,
			EvolvingStones.mint.selector,
			true
		);
	}

	function setupOlymp(Authority authority, Olymp olymp) {
		authority.setRoleCapability(
			Roles.OlympMinter,
			olymp,
			Olymp.mint.selector,
			true
		);
	}

	function setupPowder(Authority authority, Powder powder) {
		authority.setRoleCapability(
			Roles.PowderMinter,
			powder,
			Powder.mint.selector,
			true
		);
	}

	function setupTraining(Authority authority, Training training) {
		authority.setUserRole(training, Roles.PowderMinter, true);
	}
}
