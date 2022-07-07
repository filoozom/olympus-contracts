// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract NonTransferableERC20 {
	event Transfer(address indexed from, address indexed to, uint256 amount);

	string public name;
	string public symbol;
	uint8 public immutable decimals;

	uint256 public totalSupply;
	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) public allowance;

	constructor(
		string memory _name,
		string memory _symbol,
		uint8 _decimals
	) {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
	}

	// Transfer and approval
	function approve(address, uint256) public virtual returns (bool) {
		revert('NOT_IMPLEMENTED');
	}

	function transfer(address, uint256) public virtual returns (bool) {
		revert('NOT_IMPLEMENTED');
	}

	function transferFrom(
		address,
		address,
		uint256
	) public virtual returns (bool) {
		revert('NOT_IMPLEMENTED');
	}

	// Mint and burn
	function _mint(address to, uint256 amount) internal virtual {
		totalSupply += amount;

		unchecked {
			balanceOf[to] += amount;
		}

		emit Transfer(address(0), to, amount);
	}

	function _burn(address from, uint256 amount) internal virtual {
		balanceOf[from] -= amount;

		unchecked {
			totalSupply -= amount;
		}

		emit Transfer(from, address(0), amount);
	}
}
