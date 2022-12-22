// contracts/CallerContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./EthPriceOracleInterface.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract CallerContract is Ownable {
    uint256 private ethPrice;
    address private oracleAddress;
    EthPriceOracleInterface private oracleInstance;
    mapping(uint256 => bool) myRequests;

    event NewOracleAddressEvent(address oracleAddress);
    event ReceivedNewRequestIdEvent(uint256 id);
    event PriceUpdatedEvent(uint256 ethPrice, uint256 requestId);

    function setOracleInstanceAddress(address _oracleInstanceAddress) public {
        oracleAddress = _oracleInstanceAddress;
        oracleInstance = EthPriceOracleInterface(oracleAddress);

        emit NewOracleAddressEvent(oracleAddress);
    }

    function updateEthPrice() public {
        uint256 requestId = oracleInstance.getLatestEthPrice();
        myRequests[requestId] = true;

        emit ReceivedNewRequestIdEvent(requestId);
    }

    function callback(uint256 _ethPrice, uint256 _requestId) public onlyOracle {
        require(myRequests[_requestId], "This request is not in my pending list.");
        ethPrice = _ethPrice;
        delete myRequests[_requestId];

        emit PriceUpdatedEvent(_ethPrice, _requestId);
    }

    modifier onlyOracle() {
      require(msg.sender == oracleAddress, "You are not authorized to call this function.");
      _;
    }
}