// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 宣告合約的擁有者
// mainet 都會使用
// 此合約的作用：
// 1. 只有此 owner 才可以設定 new owner
// 2. 某些 function 只有 owner 才可以呼叫

// state variables
// global variables
// function modifier
// function
// error handling

contract Owanable {
    address public owner;

    constructor() {
        owner = msg.sender;
        owners.push(msg.sender);
    }

    // 宣告 modifier 以利 function 使用它來控制只有 owner 才可以呼叫
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // 為何未宣告 visibility 外部就可以呼叫？ => week3 - 因為 function visibility default 為 public 。
    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "invalid address");
        owner = _newOwner;
    }

    function onlyOwnerCanCallThisFunc() external onlyOwner {
        // code
    }

    function anyOneCanCall() external {
        // code
    }

    // 多組 owners 
    address[] public owners;

    modifier onlyOwners() {
        require(msg.sender != address(0), "invalid address");
        bool exist = false;
        for (uint i = 0; i <= owners.length; i++) {
            if (msg.sender == owners[i]) {
                exist = true;
                break;
            }
        }
        require(exist == true, "not one of owners");
        _;
    }

    function setOwners(address _newOwner) external onlyOwners {
        require(_newOwner != address(0), "invalid address");
        owners.push(_newOwner);
    }

    function removeOwners(address _removeOwner) external onlyOwners {
        require(_removeOwner != address(0), "invalid address");
        for (uint i = 0; i <= owners.length; i++) {
            if (_removeOwner == owners[i]) {
                delete owners[i];
                break;
            }
        }
    }

    function onlyOwnersCanCallThisFunc() external onlyOwners {
        // code
    }
}