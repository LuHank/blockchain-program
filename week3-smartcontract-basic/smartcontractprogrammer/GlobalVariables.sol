// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract GlobalVariables {
    function globalVars() public view returns (address, uint, uint) {
        address sender = msg.sender; // Global Variables - 呼叫此合約方法的錢包地址
        uint timestamp = block.timestamp; // Global Variables - 呼叫此方法的當時時間 unix timestamp
        uint blockNum = block.number; // Gloval Variables - 區塊高度
        return (sender, timestamp, blockNum);
    }
}