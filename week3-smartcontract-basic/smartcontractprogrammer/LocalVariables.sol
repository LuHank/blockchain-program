// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// state variables 儲存在 blockchain
// local variables 只能在 function 內使用
contract LocalVariables {
    uint public i;
    bool public b;
    address public myAddress;
    function foo() external {
        // local varaibles
        uint x = 123;
        bool f = false;
        // more code
        // 這些改變，待 function 執行完，就會不見，因為是 local variables 。
        x += 456;
        f = true;

        // state variables update value
        // 這些改變將會儲存在 blockchain
        i = 123;
        b = true;
        myAddress = address(1); // 0x0000000000000000000000000000000000000001
    }
}