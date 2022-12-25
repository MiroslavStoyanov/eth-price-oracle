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

    using SafeMath for uint256;

    CallerContractInterface private callerContractInstance;

    uint private randNonce = 0;
    uint private modulus = 1000;
    uint private numOracles = 0;
    uint private THRESHOLD = 0;
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

        uint numResponses = requestIdToResponse[_id].length;

        if (numResponses == THRESHOLD) {
            uint computedEthPrice = 0;
            for (uint f = 0; f < requestIdToResponse[_id].length; f++) {
                computedEthPrice = computedEthPrice.add(requestIdToResponse[_id][f].ethPrice);
            }
            computedEthPrice = computedEthPrice.div(numResponses);

            delete pendingRequests[_requestId];
            delete requestIdToResponse[_id];

            CallerContractInterface callerContractInstance;
            callerContractInstance = CallerContractInterface(_callerAddress);
            callerContractInstance.callback(computedEthPrice, _id);
            emit SetLatestEthPriceEvent(computedEthPrice, _callerAddress);
        }
    }
}