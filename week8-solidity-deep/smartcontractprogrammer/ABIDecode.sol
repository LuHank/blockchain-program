// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ABIDecode {
    struct MyStruct {
        string name;
        uint[2] nums;
    }

    function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        MyStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }

    function dencode(bytes calldata data) external pure 
        returns (
            uint x,
            address addr,
            // 因為會把 decode 回傳的值修改以下，所以不能宣告為不可更動的 calldata 型態 。
            uint[] memory arr,
            MyStruct memory myStruct
        ) 
    {
        // 因為在 returns 有宣告變數，所以不需要明確寫型態以及寫 return 。
        // 把 data decode 成 (uint, address, uint[], MyStruct) 等 data types 。
        // 也就是 decode 第二個參數是放要把資料 decode 成甚麼樣的 data types
        (x, addr, arr, myStruct) = abi.decode(data, (uint, address, uint[], MyStruct));
    }
}

// 執行
// encode 輸入
// x 1
// addr 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// arr 3,4,5
// myStruct ["solidity",[7,9]]