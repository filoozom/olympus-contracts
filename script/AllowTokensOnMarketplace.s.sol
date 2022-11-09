// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Script.sol';

// Contracts
import { Marketplace, Types } from 'src/Marketplace.sol';

contract AllowTokensOnMarketplaceScript is Script {
	// Testnet
	Marketplace marketplace =
		Marketplace(0xE6Ac23fb3A07ba45a44cC245F9F85Fb2bfec0dCb);

	// Production
	/*
	Marketplace marketplace =
		Marketplace(0x423417a73b684fe88d35858449840055b0fcec12);
	*/

	function setUp() public {}

	function run() public {
		vm.startBroadcast();

		// Allow tokens
		// Testnet
		marketplace.allowToken(
			0x3228adc2BE20b9058D3DC2d1e7fC5D0716ba8e61,
			Types.ERC721
		);
		marketplace.allowToken(
			0x1577C7b7E3B36bbB323E98b089BBeb7f6065D520,
			Types.ERC1155
		);

		vm.stopBroadcast();
	}
}
