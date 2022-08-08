// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Custom
import { BurnableBEP20 } from './lib/BurnableBEP20.sol';
import { MintableBEP20 } from './lib/MintableBEP20.sol';

struct Pending {
	uint64 end;
	uint8 count;
}

contract Furnace {
	BurnableBEP20 public powder;
	MintableBEP20 public stones;

	uint16 public immutable cost;
	uint32 public immutable duration;

	mapping(address => Pending) pendings;

	constructor(
		BurnableBEP20 _powder,
		MintableBEP20 _stones,
		uint16 _cost,
		uint32 _duration
	) {
		powder = _powder;
		stones = _stones;

		cost = _cost;
		duration = _duration;
	}

	function forge(uint8 count) public {
		require(pendings[msg.sender].end == 0, 'NOT_DONE');

		powder.burnFrom(msg.sender, count * cost);
		pendings[msg.sender] = Pending({
			end: uint64(block.timestamp) + duration,
			count: count
		});
	}

	function redeem() public {
		Pending storage pending = pendings[msg.sender];
		require(pending.end > 0, 'NOT_FORGING');
		require(block.timestamp >= pending.end, 'NOT_DONE');

		// More gas efficient than `delete pendings[msg.sender]`
		pending.end = 0;
		stones.mint(msg.sender, pending.count);
	}
}
