// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PayableFunction {
    int public count;
    function payableFunction() public payable {
        require(msg.value >= 0.001 ether, unicode"需至少付費 0.001 ETH");
        count += 1;
    }
}