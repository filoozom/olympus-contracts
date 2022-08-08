// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
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
		marketplace.allowToken(address(erc721), Types.ERC721);

		vm.startPrank(seller);
		erc721.approve(address(marketplace), 0);
		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC20(address(erc721), 0, 50);
	}

	function testERC20CannotListERC1155() public {
		marketplace.allowToken(address(erc1155), Types.ERC1155);

		vm.startPrank(seller);
		erc1155.setApprovalForAll(address(marketplace), true);
		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC20(address(erc1155), 5, 50);
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

	// ERC721
	function testERC721CanList() public {
		marketplace.allowToken(address(erc721), Types.ERC721);

		vm.startPrank(seller);
		erc721.approve(address(marketplace), 0);
		marketplace.listERC721(address(erc721), 0, 50);
	}

	function testERC721CannotListERC20() public {
		marketplace.allowToken(address(erc20), Types.ERC20);

		vm.startPrank(seller);
		erc20.approve(address(marketplace), 50);
		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC721(address(erc20), 50, 500);
	}

	function testERC721CannotListERC1155() public {
		marketplace.allowToken(address(erc1155), Types.ERC1155);

		vm.startPrank(seller);
		erc1155.setApprovalForAll(address(marketplace), true);
		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC721(address(erc1155), 0, 50);
	}

	function testERC721CannotListUnallowedToken() public {
		vm.startPrank(seller);
		erc721.approve(address(marketplace), 0);

		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC721(address(erc721), 0, 5);
	}

	function testERC721CannotListUnapprovedToken() public {
		marketplace.allowToken(address(erc721), Types.ERC721);

		vm.startPrank(seller);
		vm.expectRevert('NOT_AUTHORIZED');
		marketplace.listERC721(address(erc721), 0, 5);
	}

	function testERC721CanCancel() public {
		marketplace.allowToken(address(erc721), Types.ERC721);

		vm.startPrank(seller);
		erc721.approve(address(marketplace), 0);
		marketplace.listERC721(address(erc721), 0, 5);

		// Wrong cancels
		vm.expectRevert('WRONG_TOKEN');
		marketplace.cancelERC20(0);
		vm.expectRevert('WRONG_TOKEN');
		marketplace.cancelERC1155(0);

		// Right cancel
		marketplace.cancelERC721(0);

		// Make sure the seller got their NFTs back
		assertEq(erc721.ownerOf(0), seller);
	}

	function testERC721CannotCancelUnlisted() public {
		vm.expectRevert('UNAUTHORIZED');
		marketplace.cancelERC721(0);
	}

	function testERC721CanBuy() public {
		marketplace.allowToken(address(erc721), Types.ERC721);

		// List the token
		vm.startPrank(seller);
		erc721.approve(address(marketplace), 0);
		marketplace.listERC721(address(erc721), 0, 75);
		vm.stopPrank();

		// Buy the tokens
		vm.startPrank(buyer);
		currency.approve(address(marketplace), 75);
		marketplace.buyERC721(0);
		vm.stopPrank();

		// Check balances
		assertEq(currency.balanceOf(buyer), 925);
		assertEq(currency.balanceOf(seller), 75);
		assertEq(erc721.ownerOf(0), buyer);
	}

	// ERC1155
	function testERC1155CanList() public {
		marketplace.allowToken(address(erc1155), Types.ERC1155);

		vm.startPrank(seller);
		erc1155.setApprovalForAll(address(marketplace), true);
		marketplace.listERC1155(address(erc1155), 0, 5, 50);
	}

	function testERC1155CannotListERC20() public {
		marketplace.allowToken(address(erc20), Types.ERC20);

		vm.startPrank(seller);
		erc20.approve(address(marketplace), 50);
		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC1155(address(erc20), 0, 50, 500);
	}

	function testERC1155CannotListERC721() public {
		marketplace.allowToken(address(erc721), Types.ERC721);

		vm.startPrank(seller);
		erc721.approve(address(marketplace), 0);
		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC1155(address(erc721), 0, 5, 50);
	}

	function testERC1155CannotListUnallowedToken() public {
		vm.startPrank(seller);
		erc1155.setApprovalForAll(address(marketplace), true);

		vm.expectRevert('UNSUPPORTED_TOKEN');
		marketplace.listERC1155(address(erc1155), 0, 5, 5);
	}

	function testERC1155CannotListUnapprovedToken() public {
		marketplace.allowToken(address(erc1155), Types.ERC1155);

		vm.startPrank(seller);
		vm.expectRevert('NOT_AUTHORIZED');
		marketplace.listERC1155(address(erc1155), 0, 5, 5);
	}

	function testERC1155CanCancel() public {
		marketplace.allowToken(address(erc1155), Types.ERC1155);

		vm.startPrank(seller);
		erc1155.setApprovalForAll(address(marketplace), true);
		marketplace.listERC1155(address(erc1155), 0, 5, 5);

		// Wrong cancels
		vm.expectRevert('WRONG_TOKEN');
		marketplace.cancelERC20(0);
		vm.expectRevert('WRONG_TOKEN');
		marketplace.cancelERC721(0);

		// Right cancel
		marketplace.cancelERC1155(0);

		// Make sure the seller got their NFTs back
		assertEq(erc1155.balanceOf(seller, 0), 10);
	}

	function testERC1155CannotCancelUnlisted() public {
		vm.expectRevert('UNAUTHORIZED');
		marketplace.cancelERC1155(0);
	}

	function testERC1155CanBuy() public {
		marketplace.allowToken(address(erc1155), Types.ERC1155);

		// List the token
		vm.startPrank(seller);
		erc1155.setApprovalForAll(address(marketplace), true);
		marketplace.listERC1155(address(erc1155), 0, 6, 75);
		vm.stopPrank();

		// Buy the tokens
		vm.startPrank(buyer);
		currency.approve(address(marketplace), 75);
		marketplace.buyERC1155(0);
		vm.stopPrank();

		// Check balances
		assertEq(currency.balanceOf(buyer), 925);
		assertEq(currency.balanceOf(seller), 75);
		assertEq(erc1155.balanceOf(buyer, 0), 6);
		assertEq(erc1155.balanceOf(seller, 0), 4);
	}

	// Utils
	function assertEq(Types a, Types b) private {
		assertEq(uint8(a), uint8(b));
	}
}
