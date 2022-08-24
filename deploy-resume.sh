#!/bin/bash

source .env

forge script \
  script/Deploy.s.sol:DeployScript \
  --resume \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_KEY \
  -vvvv