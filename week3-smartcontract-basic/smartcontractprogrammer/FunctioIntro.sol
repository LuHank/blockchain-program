// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FucntionIntro {
    function add(uint x, uint y) external pure returns (uint) {
        return x + y;
    }

    function sub(uint x, uint y) external pure returns (uint) {
        return x - y; // 如果 x < y 就會被 revert
    }
}