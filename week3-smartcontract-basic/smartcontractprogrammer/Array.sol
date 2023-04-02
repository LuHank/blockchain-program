// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Array - dynamic or fixed size
// Initialization
// Insert (push), get, update, delete, pop, length
// Creating array in memory
// Returning array from function

contract Array {
    uint[] public nums = [1, 2, 3]; // dynamic array
    uint[3] public numsFixed = [4, 5, 6]; // fixed array

    function examples() external {
        nums.push(4); // insert - [1, 2, 3, 4]
        uint x = nums[1]; // get - 2
        nums[2] = 777; // update - third element [1, 2, 777, 4]
        delete nums[1]; // delete which reset to default value - [1, 0, 777, 4]
        nums.pop(); // pop which remove the last element
        uint len = nums.length;

        // create array in memory
        uint[] memory a = new uint[](5);
        a[1] = 123;
    }

    function returnArray() external view returns (uint[] memory) {
        return nums;
    }
}