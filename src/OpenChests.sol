// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Chainlink
import 'chainlink/interfaces/LinkTokenInterface.sol';
import 'chainlink/interfaces/VRFCoordinatorV2Interface.sol';
import 'chainlink/VRFConsumerBaseV2.sol';

// Solmate
import {ERC20} from 'solmate/tokens/ERC20.sol';
import {ERC721} from 'solmate/tokens/ERC721.sol';
import {SafeTransferLib} from 'solmate/utils/SafeTransferLib.sol';

contract OpenChests is ERC721, VRFConsumerBaseV2 {
	// Chainlink
	VRFCoordinatorV2Interface COORDINATOR;
	LinkTokenInterface LINKTOKEN;

	// Rinkeby coordinator. For other networks,
	// see https://docs.chain.link/docs/vrf-contracts/#configurations
	address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

	// Rinkeby LINK token contract. For other networks, see
	// https://docs.chain.link/docs/vrf-contracts/#configurations
	address link_token_contract = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

	// The gas lane to use, which specifies the maximum gas price to bump to.
	// For a list of available gas lanes on each network,
	// see https://docs.chain.link/docs/vrf-contracts/#configurations
	bytes32 keyHash =
		0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

	// A reasonable default is 100000, but this value could be different
	// on other networks.
	uint32 callbackGasLimit = 100000;

	// The default is 3, but you can set this higher.
	uint16 requestConfirmations = 3;

	enum State {
		Created,
		Ready
	}

	struct Chest {
		uint256 id;
		// Chainlink
		State state;
		uint256 requestId;
		uint256 requestIdIndex;
		uint256 random;
	}

	struct Range {
		uint256 from;
		uint256 amount;
	}

	struct Content {
		string character;
	}

	event ChestOpened(address indexed owner, uint256 indexed id);

	ERC20 public currency;
	address public beneficiary;
	Chest[] public chests;
	mapping(uint256 => Range) requestIdToChests;

	address s_owner;
	uint64 public s_subscriptionId;

	constructor(string memory _name, string memory _symbol)
		VRFConsumerBaseV2(vrfCoordinator)
		ERC721(_name, _symbol)
	{
		s_owner = msg.sender;
		createNewSubscription();
	}

	// Custom
	function mint(
		address to,
		uint256 id,
		uint32 amount
	) external {
		// Get random numbers
		uint256 requestId = COORDINATOR.requestRandomWords(
			keyHash,
			s_subscriptionId,
			requestConfirmations,
			callbackGasLimit,
			amount
		);

		// Mint open chests
		uint256 length = chests.length;
		for (uint256 i = 0; i < amount; ) {
			_mint(to, length + i);
			chests[length + i] = Chest({
				id: id,
				state: State.Created,
				requestId: requestId,
				requestIdIndex: i,
				random: 0
			});

			/*
            Chest storage chest = chests[length + i];

			chest.id = id;
			chest.state = State.Created;
			chest.requestId = requestId;
			chest.requestIdIndex = i;
            */

			unchecked {
				++i;
			}
		}

		requestIdToChests[requestId] = Range({from: length, amount: amount});
	}

	function contents(uint256 id) public view returns (Content memory content) {
		Chest storage chest = chests[id];
		require(chest.state != State.Created, 'NOT_READY');

		return Content({character: 'test'});
	}

	// ERC721
	function tokenURI(
		uint256 /*id*/
	) public view virtual override returns (string memory) {
		return '';
	}

	// Chainlink
	function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
		internal
		override
	{
		Range storage range = requestIdToChests[requestId];
		for (uint256 i = 0; i < range.amount; ) {
			uint256 index;
			unchecked {
				index = range.from + i;
			}

			chests[index].state = State.Ready;
			chests[index].random = randomWords[i];

			unchecked {
				++i;
			}
		}
	}

	// Create a new subscription when the contract is initially deployed.
	function createNewSubscription() private onlyOwner {
		s_subscriptionId = COORDINATOR.createSubscription();
		// Add this contract as a consumer of its own subscription.
		COORDINATOR.addConsumer(s_subscriptionId, address(this));
	}

	modifier onlyOwner() {
		require(msg.sender == s_owner);
		_;
	}
}
