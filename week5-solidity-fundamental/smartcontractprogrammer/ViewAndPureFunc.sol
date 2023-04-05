// SPDX-Licens-Identifier: MIT
pragma solidity ^0.8.7;

// pure function: 沒有讀取任何 blockchain 資料 ( state variables )。
// view function: 會讀取 blockchani 資料 ( state variables )，不會修改 state avariables。 read only without write 。

contract ViewAndPureFunctions {
    uint public num;

    function viewFunc() external view returns (uint) {
        return num;
    }

    function pureFunc() external pure returns (uint) {
        return 1;
    }

    function addToNum(uint x) external view returns (uint) {
        return num + x;
    }

    function add(uint x, uint y) external pure returns (uint) {
        return x + y;
    }
}