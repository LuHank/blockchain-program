// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// 搭配 interface.sol

// 有可能上千行，總不能全部複製過來，會造成原本自己的合約程式碼不易閱讀。
contract Counter {
    uint public count;
    uint public acount;

    function inc() external {
        count += 1;
        acount += 2;
    }

    function dec() external {
        count -= 1;
        acount -= 2;
    }
}