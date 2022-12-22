// contracts/EthPriceOracle.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./CallerContractInterface.sol";
import "openzeppelin-solidity/contracts/access/Roles.sol";

contract EthPriceOracle {
    struct Response {
        address oracleAddress;
        address callerAddress;
        uint256 ethPrice;
    }

    using Roles for Roles.Role;
    Roles.Role private owners;
    Roles.Role private oracles;

    CallerContractInterface private callerContractInstance;

    uint private randNonce = 0;
    uint private modulus = 1000;
    uint private numOracles = 0;
    mapping(uint256 => bool) pendingRequests;
    mapping (uint256 => Response[]) public requestIdToResponse;

    event GetLatestEthPriceEvent(address callerAddress, uint id);
    event SetLatestEthPriceEvent(uint256 ethPrice, address callerAddress);
    event AddOracleEvent(address oracleAddress);
    event RemoveOracleEvent(address oracleAddress);
    
    constructor(address _owner) public {
        owners.add(_owner);
    }

    function addOracle(address _oracle) public {
        require(owners.has(msg.sender), "Not an owner!");
        require(!oracles.has(_oracle), "Already an oracle!");

        oracles.add(_oracle);
        numOracles++;

        emit AddOracleEvent(_oracle);
    }

    function removeOracle(address _oracle) public {
        require(owners.has(msg.sender), "Not an owner!");
        require(oracles.has(_oracle), "Not an oracle!");
        require(numOracles > 1, "Do not remove the last oracle!");

        oracles.remove(_oracle);
        numOracles--;

        emit RemoveOracleEvent(_oracle);
    }

    function getLatestEthPrice() public returns (uint256) {
        randNonce++;
        uint requestId = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % modulus;

        pendingRequests[requestId] = true;
        emit GetLatestEthPriceEvent(msg.sender, requestId);

        return requestId;
    }

    function setLatestEthPrice(uint256 _ethPrice, address _callerAddress, uint256 _requestId) public {
        require(oracles.has(msg.sender), "Not an oracle!");
        require(pendingRequests[_requestId], "This request is not in my pending list.");

        Response memory resp;
        resp = Response(msg.sender, _callerAddress, _ethPrice);
        
        requestIdToResponse[_id].push(resp);
        delete pendingRequests[_requestId];

        callerContractInstance = CallerContractInterface(_callerAddress);
        callerContractInstance.callback(_ethPrice, _requestId);

        emit SetLatestEthPriceEvent(_ethPrice, _callerAddress);
    }
}