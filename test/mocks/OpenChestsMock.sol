// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Custom
import { IOpenChests } from 'src/interfaces/IOpenChests.sol';

contract OpenChestsMock is IOpenChests {
	event OpenChestsMinted(address indexed to, uint256 indexed chestId);

	function mint(address to, uint256 chestId) external {
		emit OpenChestsMinted(to, chestId);
	}
}
