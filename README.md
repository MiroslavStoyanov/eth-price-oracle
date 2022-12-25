# Sample Ether Price Oracle
## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)

## General info
This is a sample implementation of an Ether price oracle that provides the latest ETH price to a smart contract. Since smart contracts do not have access to the outside world, they pull data through the so-called `oracle`.

### What is an oracle?

A price oracle is a smart contract that retrieves and publishes real-time prices for a particular asset or cryptocurrency. It acts as a source of truth for the current price of the asset and is used to facilitate transactions that are pegged to the price of the asset.

Price oracles operate by fetching price data from external sources, such as exchanges or market data providers, and publishing it to the blockchain. They use cryptographic techniques to ensure the integrity and security of the price data.

## Technologies
Project is created with:
* [Solidity](https://docs.soliditylang.org/en/latest/) version: 0.8.9
* [Truffle](https://trufflesuite.com/truffle/) version: 5.6.7

## Setup
To run this project, install it locally using npm:

```
$ npm install
```