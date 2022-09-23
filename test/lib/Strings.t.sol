// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Test.sol';

// Custom
import { Strings } from 'src/lib/Strings.sol';

contract StringsTest is Test {
	function setUp() public {}

	function testEncode() public {
		assertEq(
			Strings.toHexString(0, 32),
			'0000000000000000000000000000000000000000000000000000000000000000'
		);
		assertEq(
			Strings.toHexString(7, 32),
			'0000000000000000000000000000000000000000000000000000000000000007'
		);
		assertEq(
			Strings.toHexString(15, 32),
			'000000000000000000000000000000000000000000000000000000000000000f'
		);
		assertEq(
			Strings.toHexString(type(uint256).max, 32),
			'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
		);
	}
}
