// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// 1. 讓 function 能夠 send and receive ether
//    deposit function can receive ether
//      when someone call the function will be able to send the ether
// 2. 讓 address 能夠 send the ether

contract Payable {
    address payable public owner; // payable 需再 public 前面 address 後面

    constructor() {
        // 因為 owner 有宣告 payable ，所以 msg.sender 需轉型。
        owner = payable(msg.sender);
    }

    function deposit() external payable { // 如果未宣告 payable ，則呼叫時帶 msg.value = 1 wei ，也就是傳 ether ，則交易會失敗。
        
    }

    function getBalance() external view returns (uint) {
        return address(this).balance; // 回傳合約的餘額
    }
}