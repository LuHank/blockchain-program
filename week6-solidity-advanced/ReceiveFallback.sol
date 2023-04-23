// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ReceiveFallback {
    string public status;
    // function receiveFallback(uint _x) public pure returns (uint) {
    //     return _x++;
    // }
    receive() external payable {
        status = "receive";
    }
    fallback() external payable {
        status = "fallback";
    }
}