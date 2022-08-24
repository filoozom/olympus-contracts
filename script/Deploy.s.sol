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

// Mocks
import { Currency } from './mocks/Currency.sol';

// Data
import { AuthorityData } from './data/AuthorityData.sol';
import { CharactersData } from './data/CharactersData.sol';
import { ChestsData } from './data/ChestsData.sol';
import { OpenChestsData } from './data/OpenChestsData.sol';
import { TrainingData } from './data/TrainingData.sol';

// Contracts
import { Characters } from 'src/Characters.sol';
import { Chests } from 'src/Chests.sol';
import { Furnace } from 'src/Furnace.sol';
import { Marketplace, Types } from 'src/Marketplace.sol';
import { Olymp } from 'src/Olymp.sol';
import { OpenChests, ChainlinkConfig, MintConfig } from 'src/OpenChests.sol';
import { Powder } from 'src/Powder.sol';
import { Stones } from 'src/Stones.sol';
import { Training } from 'src/Training.sol';

contract DeployScript is Script, AuthorityUtils {
	// Owner and beneficiary
	address constant beneficiary = address(0x1);

	// Characters
	string charactersName = 'Characters';
	string charactersSymbol = 'CHAR';

	// Olymp
	string olympName = 'Olymp';
	string olympSymbol = 'OL';

	// OpenChests
	string openChestsName = 'OpenChests';
	string openChestsSymbol = 'OPN';

	// Powder
	string powderName = 'Powder';
	string powderSymbol = 'POW';

	// Stones
	string stonesName = 'Stones';
	string stonesSymbol = 'STON';

	// Furnace
	uint16 furnaceCost = 100;
	uint32 furnaceDuration = 8 hours;

	/* Production */
	/*
	// Currency
	ERC20 constant currency =
		address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

	// OpenChests
	ChainlinkConfig chainlinkConfig =
		ChainlinkConfig({
			coordinator: VRFCoordinatorV2Interface(
				address(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE)
			),
			callbackGasLimit: 500000,
			requestConfirmations: 3,
			keyHash: 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04,
			subscriptionId: 0
		});
	*/

	/* Testnet */
	// Currency
	ERC20 currency;

	// OpenChests
	ChainlinkConfig chainlinkConfig =
		ChainlinkConfig({
			coordinator: VRFCoordinatorV2Interface(
				address(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f)
			),
			callbackGasLimit: 500000,
			requestConfirmations: 3,
			keyHash: 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314,
			subscriptionId: 1617
		});

	function setUp() public {
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
		deployAuthority();

		// Step 1
		Marketplace marketplace = deployMarketplace(authority);
		Stones stones = deployStones(authority);
		Olymp olymp = deployOlymp(authority);
		Powder powder = deployPowder(authority);

		// Step 2
		Characters characters = deployCharacters(authority, stones);
		Furnace furnace = deployFurnace(powder, stones);

		// Step 3
		Training training = deployTraining(characters, powder);
		OpenChests openChests = deployOpenChests(
			authority,
			MintConfig({
				characters: characters,
				olymp: olymp,
				powder: powder,
				stones: stones
			})
		);

		// Step 4
		Chests chests = deployChests(openChests);

		/* Configure */
		// Authority
		setupCharacters(characters);
		setupChests(chests);
		setupFurnace(furnace);
		setupMarketplace(marketplace);
		setupOlymp(olymp);
		setupOpenChests(openChests);
		setupPowder(powder);
		setupStones(stones);
		setupTraining(training);

		// Marketplace
		marketplace.allowToken(address(characters), Types.ERC721);
		marketplace.allowToken(address(chests), Types.ERC1155);
		marketplace.allowToken(address(stones), Types.ERC20);

		vm.stopBroadcast();
	}

	function deployCharacters(RolesAuthority authority, Stones stones)
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
				CharactersData.getLevelCosts()
			);
	}

	function deployChests(OpenChests openChests) private returns (Chests) {
		return
			new Chests(currency, beneficiary, openChests, ChestsData.getChests());
	}

	function deployFurnace(Powder powder, Stones stones)
		private
		returns (Furnace)
	{
		return new Furnace(powder, stones, furnaceCost, furnaceDuration);
	}

	function deployMarketplace(RolesAuthority authority)
		private
		returns (Marketplace)
	{
		return new Marketplace(currency, owner, authority);
	}

	function deployOlymp(RolesAuthority authority) private returns (Olymp) {
		return new Olymp(olympName, olympSymbol, owner, authority);
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
				OpenChestsData.getConfigs()
			);
	}

	function deployPowder(RolesAuthority authority) private returns (Powder) {
		return new Powder(powderName, powderSymbol, owner, authority);
	}

	function deployStones(RolesAuthority authority) private returns (Stones) {
		return new Stones(stonesName, stonesSymbol, owner, authority);
	}

	function deployTraining(Characters characters, Powder powder)
		private
		returns (Training)
	{
		return
			new Training(
				characters,
				powder,
				TrainingData.getDurations(),
				TrainingData.getProbabilities()
			);
	}
}
