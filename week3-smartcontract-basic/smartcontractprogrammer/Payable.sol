// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PayableFunction {
    int public count;
    function payableFunction() public payable {
        require(msg.value >= 0.001 ether);
        count += 1;
    }
}