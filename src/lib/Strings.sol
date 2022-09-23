// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

library Strings {
	bytes16 private constant _SYMBOLS = '0123456789abcdef';

	// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aa4b9017882a9ef221648d0768dcf2a8436d869c/contracts/utils/Strings.sol#L52-L62
	function toHexString(uint256 value, uint256 length)
		internal
		pure
		returns (string memory)
	{
		bytes memory buffer = new bytes(2 * length);
		for (uint256 i = 2 * length + 1; i > 1; --i) {
			buffer[i - 2] = _SYMBOLS[value & 0xf];
			value >>= 4;
		}
		require(value == 0, 'Strings: hex length insufficient');
		return string(buffer);
	}
}
