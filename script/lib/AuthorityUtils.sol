// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Solmate
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { Characters } from 'src/Characters.sol';
import { Chests } from 'src/Chests.sol';
import { Furnace } from 'src/Furnace.sol';
import { Marketplace } from 'src/Marketplace.sol';
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
	OpenChestsMinter,
	MarketplaceTokenAllower,
	MarketplaceCurrencySetter
}

struct TrainingConfig {
	Training training;
	Powder powder;
}

contract AuthorityUtils {
	address owner;
	RolesAuthority authority;

	function deployAuthority() public {
		authority = new RolesAuthority(owner, Authority(address(0)));
	}

	function setRoleCapability(
		uint8 role,
		address target,
		bytes4 functionSig
	) private {
		authority.setRoleCapability(role, target, functionSig, true);
	}

	function setupCharacters(Characters characters) public {
		setRoleCapability(
			uint8(Roles.CharactersMinter),
			address(characters),
			Characters.mint.selector
		);
	}

	function setupChests(Chests chests) public {
		authority.setUserRole(address(chests), uint8(Roles.OpenChestsMinter), true);
	}

	function setupFurnace(Furnace furnace) public {
		authority.setUserRole(address(furnace), uint8(Roles.StonesMinter), true);
	}

	function setupMarketplace(Marketplace marketplace) public {
		address addr = address(marketplace);
		authority.setUserRole(addr, uint8(Roles.MarketplaceTokenAllower), true);
		authority.setUserRole(addr, uint8(Roles.MarketplaceCurrencySetter), true);
	}

	function setupOlymp(Olymp olymp) public {
		setRoleCapability(
			uint8(Roles.OlympMinter),
			address(olymp),
			MintableBEP20.mint.selector
		);
	}

	function setupOpenChests(OpenChests openChests) public {
		setRoleCapability(
			uint8(Roles.OpenChestsMinter),
			address(openChests),
			OpenChests.mint.selector
		);

		address addr = address(openChests);
		authority.setUserRole(addr, uint8(Roles.PowderMinter), true);
		authority.setUserRole(addr, uint8(Roles.OlympMinter), true);
		authority.setUserRole(addr, uint8(Roles.StonesMinter), true);
		authority.setUserRole(addr, uint8(Roles.CharactersMinter), true);
	}

	function setupPowder(Powder powder) public {
		setRoleCapability(
			uint8(Roles.PowderMinter),
			address(powder),
			MintableBEP20.mint.selector
		);
	}

	function setupStones(Stones stones) public {
		setRoleCapability(
			uint8(Roles.StonesMinter),
			address(stones),
			MintableBEP20.mint.selector
		);
	}

	function setupTraining(Training training) public {
		authority.setUserRole(address(training), uint8(Roles.PowderMinter), true);
	}
}
