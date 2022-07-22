// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'forge-std/Test.sol';

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC721 } from 'solmate/tokens/ERC721.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Custom
import { ERC20Mock } from './mocks/ERC20Mock.sol';
import { ERC721Mock } from './mocks/ERC721Mock.sol';
import { ERC1155Mock } from './mocks/ERC1155Mock.sol';
import { Marketplace, Types } from 'src/Marketplace.sol';

contract MarketplaceTest is Test {
	ERC20Mock erc20;
	ERC721Mock erc721;
	ERC1155Mock erc1155;

	ERC20Mock currency;
	Marketplace marketplace;

	address seller = address(1);
	address buyer = address(2);

	function setUp() public {
		// Tokens
		erc20 = new ERC20Mock('ERC20', 'ERC20');
		erc721 = new ERC721Mock('ERC721', 'ERC721');
		erc1155 = new ERC1155Mock();

		// Currency
		currency = new ERC20Mock('BUSD', 'BUSD');

		// Marketplace
		marketplace = new Marketplace(
			currency,
			address(this),
			Authority(address(0))
		);

		// Mint tokens
		erc20.mint(seller, 500);
		erc721.mint(seller, 0);
		erc721.mint(seller, 1);
		erc1155.mint(seller, 0, 10);
		erc1155.mint(seller, 1, 10);

		// Mint currency
		currency.mint(buyer, 1000);
	}

	function testCanChangeCurrency() public {
		assertEq(address(marketplace.currency()), address(currency));

		ERC20 newCurrency = ERC20(address(123));
		marketplace.setCurrency(newCurrency);
		assertEq(address(marketplace.currency()), address(newCurrency));
	}

	function testCanAllowTokens() public {
		marketplace.allowToken(address(erc20), Types.ERC20);
		marketplace.allowToken(address(erc721), Types.ERC721);
		marketplace.allowToken(address(erc1155), Types.ERC1155);

		assertEq(marketplace.allowedTokens(address(erc20)), Types.ERC20);
		assertEq(marketplace.allowedTokens(address(erc721)), Types.ERC721);
		assertEq(marketplace.allowedTokens(address(erc1155)), Types.ERC1155);

		// Disallow a currently allowed token
		marketplace.allowToken(address(erc20), Types.Unsupported);
		assertEq(marketplace.allowedTokens(address(erc20)), Types.Unsupported);
	}

	// ERC20
	function testERC20CanList() public {
		marketplace.allowToken(address(erc20), Types.ERC20);

		vm.startPrank(seller);
		erc20.approve(address(marketplace), 50);
		marketplace.listERC20(address(erc20), 50, 500);
	}

	function testERC20CannotListERC721() public {
		// TODO
	}

	function testERC20CannotListERC1155() public {
		// TODO
	}

	function testERC20CannotListUnallowedToken() public {
		vm.startPrank(seller);
		erc20.approve(address(marketplace), 50);

		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC20(address(erc20), 50, 5);
	}

	function testERC20CannotListUnapprovedToken() public {
		marketplace.allowToken(address(erc20), Types.ERC20);

		vm.startPrank(seller);
		vm.expectRevert('TRANSFER_FROM_FAILED');
		marketplace.listERC20(address(erc20), 50, 5);
	}

	function testERC20CanCancel() public {
		marketplace.allowToken(address(erc20), Types.ERC20);

		vm.startPrank(seller);
		erc20.approve(address(marketplace), 50);
		marketplace.listERC20(address(erc20), 50, 5);

		// Wrong cancels
		vm.expectRevert('WRONG_TOKEN');
		marketplace.cancelERC721(0);
		vm.expectRevert('WRONG_TOKEN');
		marketplace.cancelERC1155(0);

		// Right cancel
		marketplace.cancelERC20(0);

		// Make sure the seller got their NFTs back
		assertEq(erc20.balanceOf(seller), 500);
	}

	function testERC20CannotCancelUnlisted() public {
		vm.expectRevert('UNAUTHORIZED');
		marketplace.cancelERC20(0);
	}

	function testERC20CanBuy() public {
		marketplace.allowToken(address(erc20), Types.ERC20);

		// List the token
		vm.startPrank(seller);
		erc20.approve(address(marketplace), 5);
		marketplace.listERC20(address(erc20), 5, 75);
		vm.stopPrank();

		// Buy the tokens
		vm.startPrank(buyer);
		currency.approve(address(marketplace), 75);
		marketplace.buyERC20(0);
		vm.stopPrank();

		// Check balances
		assertEq(currency.balanceOf(buyer), 925);
		assertEq(currency.balanceOf(seller), 75);
		assertEq(erc20.balanceOf(seller), 495);
		assertEq(erc20.balanceOf(buyer), 5);
	}

	// Utils
	function assertEq(Types a, Types b) private {
		assertEq(uint8(a), uint8(b));
	}
}