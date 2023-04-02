// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Mapping
// How to declare a mapping (simple and nested)
// Set, get, delete

contract Mapping {
    mapping(address => uint) public balances; // 利用錢包地址查詢餘額
    mapping(address => mapping(address => bool)) public isFriend; // A 地址與 B 地址是否為 Friend

    uint public bal;
    uint public bal2;

    function examples() external {
        balances[msg.sender] = 123; // set mapping
        // uint bal = balances[msg.sender]; // get mapping
        // uint bal2 = balances[address(1)]; // 沒有 2rd address 資料，因此帶入預設值 0
        bal = balances[msg.sender]; // 驗證
        bal2 = balances[address(1)]; // 驗證
        // uint storage bal = balances[msg.sender]; // storage 只能用在 array, struct, mapping

        balances[msg.sender] += 456; // 123 + 456 = 579
        
        delete balances[msg.sender]; // reset to 0

        isFriend[msg.sender][address(this)] = true; 

    }
}