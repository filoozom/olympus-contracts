// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Script.sol';

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';

// Lib
import { AuthorityUtils } from './lib/AuthorityUtils.sol';

// Contracts
import { BonusChests } from 'src/BonusChests.sol';
import { Characters } from 'src/Characters.sol';
import { Chests } from 'src/Chests.sol';
import { Marketplace, Types } from 'src/Marketplace.sol';
import { Stones } from 'src/Stones.sol';

contract DeployMarketplaceScript is Script, AuthorityUtils {
	// Fees
	address beneficiary = 0x11632134F596C26ee0775Df3c807c1cC33E22eF0;
	uint256 fee = 500;

	// Testnet
	/*
	ERC20 currency = ERC20(0xa9BeF92eD63C997b418A86E0E14a4fE79e639f5A);
	RolesAuthority rolesAuthority =
		RolesAuthority(0x37D98eDb9C93c8E70ec737E9c51d16C908fBb33b);
	*/

	// Production
	ERC20 currency = ERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
	RolesAuthority rolesAuthority =
		RolesAuthority(0x7b1fd50a4a046858575a0794a5d05Ae4170469a9);

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
		// Production
		// Characters
		marketplace.allowToken(
			0xfdeF2aB73198C196CBceBD0c33A77CB1CD907729,
			Types.ERC721
		);
		marketplace.allowToken(
			0x4a2E149C0e37D8970c85cDA99a3DeFfe70999CAF,
			Types.ERC721
		);

		// Stones
		marketplace.allowToken(
			0x20d9E48C39AeE6F21281827CFeE76eBa3366097d,
			Types.ERC20
		);

		// Chests
		marketplace.allowToken(
			0xFe6af84fd3415f94FBB41Dac8EA558a758Ea138f,
			Types.ERC1155
		);
		marketplace.allowToken(
			0x26Fdd867f09B26440259f550ecb36D07A0cD954F,
			Types.ERC721
		);

		vm.stopBroadcast();
	}

	function deployMarketplace() private returns (Marketplace) {
		return new Marketplace(currency, owner, authority, beneficiary, fee);
	}
}
