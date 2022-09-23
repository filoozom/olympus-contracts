// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Test.sol';

// Chainlink
import { VRFCoordinatorV2Mock } from 'chainlink/mocks/VRFCoordinatorV2Mock.sol';

// Solmate
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { ERC1155 } from 'solmate/tokens/ERC1155.sol';
import { Authority } from 'solmate/auth/Auth.sol';
import { LibString } from 'solmate/utils/LibString.sol';

// Custom
import { Chests, Chest } from 'src/Chests.sol';
import { Characters, Rarities } from 'src/Characters.sol';
import { Stones } from 'src/Stones.sol';
import { MintableBEP20 } from 'src/lib/MintableBEP20.sol';
import { BurnableBEP20 } from 'src/lib/BurnableBEP20.sol';
import { Olymp } from 'src/Olymp.sol';
import { Powder } from 'src/Powder.sol';
import { MintConfig, ChainlinkConfig } from 'src/OpenChests.sol';
import { MintableBEP20 } from 'src/lib/MintableBEP20.sol';
import { OpenChests } from 'src/OpenChests.sol';

// Mocks
import { ERC20Mock } from './mocks/ERC20Mock.sol';

// Data
import { CharactersData } from 'script/data/CharactersData.sol';
import { ChestsData } from 'script/data/ChestsData.sol';
import { OpenChestsData } from 'script/data/OpenChestsData.sol';
import { AuthorityData } from 'script/data/AuthorityData.sol';

contract OpenChestsTest is Test {
	// Events
	event ChestClaimed(uint256 indexed id, uint256 random);
	event RandomWordsFulfilled(
		uint256 indexed requestId,
		uint256 outputSeed,
		uint96 payment,
		bool success
	);
	event RandomWordsRequested(
		bytes32 indexed keyHash,
		uint256 requestId,
		uint256 preSeed,
		uint64 indexed subId,
		uint16 minimumRequestConfirmations,
		uint32 callbackGasLimit,
		uint32 numWords,
		address indexed sender
	);

	// Dependencies
	VRFCoordinatorV2Mock coordinator;

	// Configs
	MintConfig mintConfig;
	ChainlinkConfig chainlinkConfig;

	// Settings
	address recipient = address(99);

	// Short variables
	Authority authority = AuthorityData.getNull();

	// Instance
	OpenChests chests;

	function setUpMintConfig() private {
		// Dependencies
		Stones stones = new Stones('Stones', 'EST', address(this), authority);
		Olymp olymp = new Olymp('bOlymp', 'bOlymp', address(this), authority);
		Powder powder = new Powder('Powder', 'POW', address(this), authority);
		Characters characters = new Characters(
			'Characters',
			'CHAR',
			address(this),
			authority,
			BurnableBEP20(address(stones)),
			CharactersData.getLevelCosts(),
			''
		);

		// Mint config
		mintConfig = MintConfig({
			characters: characters,
			olymp: olymp,
			powder: powder,
			stones: stones
		});
	}

	function setUpChainlinkConfig() private {
		coordinator = new VRFCoordinatorV2Mock(0, 0);
		uint64 subscriptionId = coordinator.createSubscription();

		// Chainlink config
		chainlinkConfig = ChainlinkConfig({
			coordinator: coordinator,
			callbackGasLimit: 500000,
			requestConfirmations: 3,
			keyHash: 0,
			subscriptionId: subscriptionId
		});
	}

	function setUp() public {
		setUpMintConfig();
		setUpChainlinkConfig();

		// Chests
		chests = new OpenChests(
			'Open Chests',
			'OCH',
			address(this),
			authority,
			chainlinkConfig,
			mintConfig,
			OpenChestsData.getConfigs(),
			'http://example.com/open-chests/'
		);

		// Set roles
		mintConfig.characters.setOwner(address(chests));
		mintConfig.olymp.setOwner(address(chests));
		mintConfig.powder.setOwner(address(chests));
		mintConfig.stones.setOwner(address(chests));

		// Add consumer
		coordinator.addConsumer(chainlinkConfig.subscriptionId, address(chests));

		// We need at least 64 mined blocks for randomness
		vm.roll(64);
	}

	function testCanMintAllChests() public {
		address user = address(42);

		chests.mint(user, 0);
		chests.mint(user, 1);
		chests.mint(user, 2);
		chests.mint(user, 3);
	}

	function testCannotMintChestIfNotAuthorized() public {
		address user = address(42);

		vm.prank(address(80));
		vm.expectRevert('UNAUTHORIZED');
		chests.mint(user, 0);
	}

	function testCanOpen() public {
		address user = address(42);
		uint256 requestId;

		// Mint one chest
		vm.recordLogs();
		chests.mint(user, 3);
		Vm.Log[] memory logs = vm.getRecordedLogs();

		// Fetch the requestId
		for (uint256 i = 0; i < logs.length; i++) {
			if (logs[i].topics[0] == RandomWordsRequested.selector) {
				requestId = abi.decode(logs[i].data, (uint256));
				break;
			}
		}

		// Create a random word
		uint256[] memory randomWords = new uint256[](1);
		randomWords[0] = uint256(keccak256(abi.encode(requestId, 0)));

		// Fulfill the random word and expect the ChestClaimed event
		vm.expectEmit(true, true, true, true);
		emit ChestClaimed(1, randomWords[0]);
		coordinator.fulfillRandomWordsWithOverride(
			requestId,
			address(chests),
			randomWords
		);

		// Reused variables
		uint256 balance;

		// Check olymp balance
		balance = mintConfig.olymp.balanceOf(user);
		assertTrue(
			balance == 0 || balance == 1600 || balance == 3200 || balance == 6400
		);

		// Check powder balance
		balance = mintConfig.powder.balanceOf(user);
		assertTrue(balance == 80 || balance == 160 || balance == 400);

		// Make sure only one character was minted
		assertEq(mintConfig.characters.ownerOf(0), user);
		vm.expectRevert('NOT_MINTED');
		mintConfig.characters.ownerOf(1);
	}

	function testCanOpenAllChests() public {
		address user = address(42);

		for (uint8 chest = 0; chest < 4; chest++) {
			for (uint8 i = 0; i < 5; i++) {
				chests.mint(user, chest);
			}
		}

		// Fulfill random words for each minted chest
		for (uint256 requestId = 1; requestId <= 20; requestId++) {
			coordinator.fulfillRandomWords(requestId, address(chests));
		}
	}

	function testTokenUri() public {
		address user = address(42);

		string memory uri0 = 'http://example.com/open-chests/0.json';
		string memory uri1 = 'http://example.com/open-chests/1.json';
		string memory uri2 = 'http://example.com/open-chests/2.json';
		string memory uri3 = 'http://example.com/open-chests/3.json';

		chests.mint(user, 0);
		chests.mint(user, 0);
		chests.mint(user, 1);
		chests.mint(user, 1);
		chests.mint(user, 2);
		chests.mint(user, 3);

		assertEq(chests.tokenURI(1), uri0);
		assertEq(chests.tokenURI(2), uri0);
		assertEq(chests.tokenURI(3), uri1);
		assertEq(chests.tokenURI(4), uri1);
		assertEq(chests.tokenURI(5), uri2);
		assertEq(chests.tokenURI(6), uri3);
	}
}
