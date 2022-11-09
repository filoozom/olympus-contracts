// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import 'forge-std/Script.sol';

// Chainlink
import { VRFCoordinatorV2Interface } from 'chainlink/interfaces/VRFCoordinatorV2Interface.sol';

// Solmate
import { RolesAuthority } from 'solmate/auth/authorities/RolesAuthority.sol';
import { ERC20 } from 'solmate/tokens/ERC20.sol';
import { Authority } from 'solmate/auth/Auth.sol';

// Lib
import { AuthorityUtils } from './lib/AuthorityUtils.sol';
import { ToDynamicUtils } from './lib/ToDynamicUtils.sol';

// Mocks
import { Currency } from './mocks/Currency.sol';

// Data
import { AuthorityData } from './data/AuthorityData.sol';
import { BonusChestsData } from './data/BonusChestsData.sol';
import { CharactersData } from './data/CharactersData.sol';
import { OpenChestsData } from './data/OpenChestsData.sol';
import { TrainingData } from './data/TrainingData.sol';

// Contracts
import { BonusChests } from 'src/BonusChests.sol';
import { Characters } from 'src/Characters.sol';
import { Furnace } from 'src/Furnace.sol';
import { Marketplace, Types } from 'src/Marketplace.sol';
import { Olymp } from 'src/Olymp.sol';
import { OpenChests, ChainlinkConfig, MintConfig } from 'src/OpenChests.sol';
import { Powder } from 'src/Powder.sol';
import { Stones } from 'src/Stones.sol';
import { Training } from 'src/Training.sol';

contract DeployV2Script is Script, AuthorityUtils {
	// Owner and beneficiary
	address constant beneficiary =
		address(0x11632134F596C26ee0775Df3c807c1cC33E22eF0);

	// Characters
	string charactersName = 'Olympus Game - Characters';
	string charactersSymbol = 'OLYMPC';

	// OpenChests
	string openChestsName = 'Olympus Game - Open Chests';
	string openChestsSymbol = 'OLYMPOC';

	// Furnace
	uint16 furnaceCost = 100;
	uint32 furnaceDuration = 8 hours;

	// Chests
	uint256 endTimestamp = block.timestamp + 30 days;

	// NFT config
	string chestsUri = 'https://nftimages.olympus.game/chests/{id}.json';
	string openChestsBaseUri = 'https://nftimages.olympus.game/open-chests/';
	string charactersBaseUri = 'https://nftimages.olympus.game/characters/';

	/* Production */
	// Deployed
	Marketplace marketplace =
		Marketplace(0x423417a73b684fE88D35858449840055B0FCEc12);
	RolesAuthority _authority =
		RolesAuthority(0x7b1fd50a4a046858575a0794a5d05Ae4170469a9);
	Stones stones = Stones(0x20d9E48C39AeE6F21281827CFeE76eBa3366097d);
	Powder powder = Powder(0x45B77Cc0a3a4C701E7C551641D6077a993d1e023);
	Olymp olymp = Olymp(0xE963D09d7DdDdAFF718500E19aFC05d67a01658C);

	// Currency
	ERC20 currency = ERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));

	// OpenChests
	ChainlinkConfig chainlinkConfig =
		ChainlinkConfig({
			coordinator: VRFCoordinatorV2Interface(
				address(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE)
			),
			callbackGasLimit: 500000,
			requestConfirmations: 3,
			keyHash: 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04,
			subscriptionId: 466
		});

	/* Testnet */
	/*
	// Deployed
	Marketplace marketplace =
		Marketplace(0xE6Ac23fb3A07ba45a44cC245F9F85Fb2bfec0dCb);
	RolesAuthority _authority =
		RolesAuthority(0x37D98eDb9C93c8E70ec737E9c51d16C908fBb33b);
	Stones stones = Stones(0x802FAf1A3a7dE4d8BebB0433AE4009a501CDb531);
	Powder powder = Powder(0xe5dbe4813C3F3F9702316FEB71479Bc6c83D99C0);
	Olymp olymp = Olymp(0xc85d243e7FC0bf2d644D5FD92e78c66af853BbA5);

	// Currency
	ERC20 currency = ERC20(0xa9BeF92eD63C997b418A86E0E14a4fE79e639f5A);

	// OpenChests
	ChainlinkConfig chainlinkConfig =
		ChainlinkConfig({
			coordinator: VRFCoordinatorV2Interface(
				address(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
			),
			callbackGasLimit: 500000,
			requestConfirmations: 3,
			keyHash: 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15,
			subscriptionId: 632
		});
	*/

	function setUp() public {
		authority = _authority;
		owner = msg.sender;
	}

	function run() public {
		vm.startBroadcast();

		if (address(currency) == address(0)) {
			currency = ERC20(
				new Currency('Currency', 'CUR', owner, Authority(address(0)))
			);
		}

		/* Deploy */
		// Step 0
		Characters characters = deployCharacters(authority);

		// Step 1
		Training training = deployTraining(characters);
		OpenChests openChests = deployOpenChests(
			authority,
			MintConfig({
				characters: characters,
				olymp: olymp,
				powder: powder,
				stones: stones
			})
		);

		// Step 2
		BonusChests bonusChests = deployBonusChests(openChests);

		/* Configure */
		// Authority
		setupCharacters(characters);
		setupBonusChests(bonusChests);
		setupOpenChests(openChests);
		setupTraining(training);

		// Marketplace
		marketplace.allowToken(address(characters), Types.ERC721);
		marketplace.allowToken(address(bonusChests), Types.ERC1155);

		vm.stopBroadcast();
	}

	function deployBonusChests(OpenChests openChests)
		private
		returns (BonusChests)
	{
		return
			new BonusChests(
				currency,
				beneficiary,
				openChests,
				BonusChestsData.getChest(),
				chestsUri,
				endTimestamp
			);
	}

	function deployCharacters(RolesAuthority authority)
		private
		returns (Characters)
	{
		return
			new Characters(
				charactersName,
				charactersSymbol,
				owner,
				authority,
				stones,
				CharactersData.getLevelCosts(),
				charactersBaseUri
			);
	}

	function deployOpenChests(
		RolesAuthority authority,
		MintConfig memory mintConfig
	) private returns (OpenChests) {
		return
			new OpenChests(
				openChestsName,
				openChestsSymbol,
				owner,
				authority,
				chainlinkConfig,
				mintConfig,
				OpenChestsData.getConfigs(),
				openChestsBaseUri
			);
	}

	function deployTraining(Characters characters) private returns (Training) {
		return
			new Training(
				characters,
				powder,
				TrainingData.getDurations(),
				TrainingData.getProbabilities()
			);
	}
}
