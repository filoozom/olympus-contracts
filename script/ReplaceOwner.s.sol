// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Script.sol';

// Solmate
import { Auth } from 'solmate/auth/Auth.sol';

contract ReplaceOwnerScript is Script {
	// New owner
	address owner = address(0x90c24696B90D531519f49b909520924299C2d852);

	function setUp() public {}

	function run() public {
		// Testnet
		Auth[11] memory contracts = [
			Auth(0xc87EE706ca6A2F6B224f820D025fBCE573612931),
			Auth(0x3228adc2BE20b9058D3DC2d1e7fC5D0716ba8e61),
			Auth(0xE6Ac23fb3A07ba45a44cC245F9F85Fb2bfec0dCb),
			Auth(0x70263aFF037b24a4F98C6cC25E0eAbB00a2206d7),
			Auth(0x91aF80F5AC26727D97272F6244143439F3C2C2aa),
			Auth(0xe5dbe4813C3F3F9702316FEB71479Bc6c83D99C0),
			Auth(0xc85d243e7FC0bf2d644D5FD92e78c66af853BbA5),
			Auth(0x802FAf1A3a7dE4d8BebB0433AE4009a501CDb531),
			Auth(0x9465DEa0aF032c00a94b1b6F582E133E6Da1cc58),
			Auth(0x37D98eDb9C93c8E70ec737E9c51d16C908fBb33b),
			Auth(0xa9BeF92eD63C997b418A86E0E14a4fE79e639f5A)
		];

		// Mainnet
		/*
		Auth[12] memory contracts = [
			Auth(0x7b1fd50a4a046858575a0794a5d05Ae4170469a9),
			Auth(0x2543A2b8bb071458d2148Dd16ff340f680c45cB7),
			Auth(0x20d9E48C39AeE6F21281827CFeE76eBa3366097d),
			Auth(0xE963D09d7DdDdAFF718500E19aFC05d67a01658C),
			Auth(0x45B77Cc0a3a4C701E7C551641D6077a993d1e023),
			Auth(0xfdeF2aB73198C196CBceBD0c33A77CB1CD907729),
			Auth(0x5D16574EddA5d355fFa1B99990899187feDDA21F),
			Auth(0x26Fdd867f09B26440259f550ecb36D07A0cD954F),
			Auth(0x423417a73b684fE88D35858449840055B0FCEc12),
			Auth(0x4a2E149C0e37D8970c85cDA99a3DeFfe70999CAF),
			Auth(0x3D66C82141aF339Bff9551C7f951d7e5330f3056),
			Auth(0xa9c265e15d1A7A7F2aC5F183AFD1add29cda99Fb)
		];
		*/

		vm.startBroadcast();

		for (uint256 i = 0; i < contracts.length; i++) {
			contracts[i].setOwner(owner);
		}

		vm.stopBroadcast();
	}
}
