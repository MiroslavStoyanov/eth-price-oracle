// contracts/EthPriceOracle.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface CallerContractInterface {
    function callback(uint256 _ethPrice, uint256 id) external;
}