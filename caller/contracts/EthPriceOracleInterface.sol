// contracts/EthPriceOracleInterface.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface EthPriceOracleInterface {
  function getLatestEthPrice() external returns (uint256);
}