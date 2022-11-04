// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Script.sol';

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';

// Lib
import { AuthorityUtils } from './lib/AuthorityUtils.sol';

// Contracts
import { Characters } from 'src/Characters.sol';
import { Chests } from 'src/Chests.sol';
import { Marketplace, Types } from 'src/Marketplace.sol';
import { Stones } from 'src/Stones.sol';

contract DeployMarketplaceScript is Script, AuthorityUtils {
	// Testnet
	ERC20 currency = ERC20(0xa9BeF92eD63C997b418A86E0E14a4fE79e639f5A);

	Characters characters =
		Characters(0x91aF80F5AC26727D97272F6244143439F3C2C2aa);
	Chests chests = Chests(0x4874a452c19eE75dAADf0E740de8643821cb3D7d);
	Stones stones = Stones(0x802FAf1A3a7dE4d8BebB0433AE4009a501CDb531);
	RolesAuthority rolesAuthority =
		RolesAuthority(0x37D98eDb9C93c8E70ec737E9c51d16C908fBb33b);

	// Production
	/*
	ERC20 currency = ERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

	Characters characters =
		Characters(0xfdeF2aB73198C196CBceBD0c33A77CB1CD907729);
	Chests chests = Chests(0x26Fdd867f09B26440259f550ecb36D07A0cD954F);
	Stones stones = Stones(0x20d9E48C39AeE6F21281827CFeE76eBa3366097d);
	RolesAuthority rolesAuthority =
		RolesAuthority(0x7b1fd50a4a046858575a0794a5d05Ae4170469a9);
	*/

	function setUp() public {
		authority = rolesAuthority;
		owner = msg.sender;
	}

	function run() public {
		vm.startBroadcast();

		Marketplace marketplace = deployMarketplace();

		// Setup roles
		setupMarketplace(marketplace);

		// Allow tokens
		marketplace.allowToken(address(characters), Types.ERC721);
		marketplace.allowToken(address(chests), Types.ERC1155);
		marketplace.allowToken(address(stones), Types.ERC20);

		vm.stopBroadcast();
	}

	function deployMarketplace() private returns (Marketplace) {
		return new Marketplace(currency, owner, authority);
	}
}
