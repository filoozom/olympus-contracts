// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Solmate
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { Characters } from 'src/Characters.sol';
import { Chests } from 'src/Chests.sol';
import { EvolvingStones } from 'src/EvolvingStones.sol';
import { Olymp } from 'src/Olymp.sol';
import { Powder } from 'src/Powder.sol';
import { Training } from 'src/Training.sol';
import { MintableERC20 } from 'src/lib/MintableERC20.sol';

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
		address addr = address(chests);
		authority.setUserRole(addr, uint8(Roles.PowderMinter), true);
		authority.setUserRole(addr, uint8(Roles.OlympMinter), true);
		authority.setUserRole(addr, uint8(Roles.EvolvingStonesMinter), true);
		authority.setUserRole(addr, uint8(Roles.CharactersMinter), true);
	}

	function setupEvolvingStones(
		RolesAuthority authority,
		EvolvingStones evolvingStones
	) public {
		authority.setRoleCapability(
			uint8(Roles.EvolvingStonesMinter),
			address(evolvingStones),
			MintableERC20.mint.selector,
			true
		);
	}

	function setupOlymp(RolesAuthority authority, Olymp olymp) public {
		authority.setRoleCapability(
			uint8(Roles.OlympMinter),
			address(olymp),
			MintableERC20.mint.selector,
			true
		);
	}

	function setupPowder(RolesAuthority authority, Powder powder) public {
		authority.setRoleCapability(
			uint8(Roles.PowderMinter),
			address(powder),
			MintableERC20.mint.selector,
			true
		);
	}

	function setupTraining(RolesAuthority authority, Training training) public {
		authority.setUserRole(address(training), uint8(Roles.PowderMinter), true);
	}
}
