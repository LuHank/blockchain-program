// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// library allow you to
// 1. seperate code logic
// 2. reuse code in other contract
// 3. enhance data types

// restrictions
// 1. 不能宣告 state variables
// 2. library function visibility 宣告為 internal ( embeded inside contract, 只需 deploy contract 不需另外對 library deploy )，因為宣告為 public(需與 contract 分開 deploy ), private (只能給 library 使用)都不合理。

library Math {
    function max(uint x, uint y) internal pure returns (uint) {
        return x >= y ? x : y; // ternary operator 比 if else 程式碼短。
    }
}

contract Text {
    function testMax(uint x, uint y) external pure returns (uint) {
        return Math.max(x, y);
    }
}

// library: 尋找陣列的數字，如果再找 2 則 index 回傳 1, 在找 3 則 index 回傳 0, 在找 4 則 function 會被 revert 。
library ArrayLib {
    // 放入陣列 arr, 尋找 x, 回傳 x 的索引
    function find(uint[] storage arr, uint x) internal view returns (uint) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == x) {
                return i;
            }
        }
        revert("not found");
    }
}

contract TestArray {
    // enhance data type
    using ArrayLib for uint[];
    uint[] public arr = [3, 2, 1];

    function testFind(uint _x) external view returns (uint i) {
        // return ArrayLib.find(arr, 2);
        return arr.find(_x); // call the function on the data type
    }
}