// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract AbiDecode {
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

    function decode(
        bytes calldata data
    )
        external
        pure
        returns (uint x, address addr, uint[] memory arr, MyStruct memory myStruct)
    {
        // (uint x, address addr, uint[] memory arr, MyStruct myStruct) = ...
        (x, addr, arr, myStruct) = abi.decode(data, (uint, address, uint[], MyStruct));
    }
}

// Remix - encode function 參數輸入
// x = 123
// addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// arr = [1,2]
// myStruct = ["hank",[3,4]]

// Remix - decode function 參數輸入
    // 輸出
    // 由於 abi.encode 將每個參數值都填充為 32 bytes，中間有很多 0。
    // 0x000000000000000000000000000000000000000000000000000000000000007b0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000468616e6b00000000000000000000000000000000000000000000000000000000
// 把 encode function 輸出結果貼上
    // 輸出
    // 0: uint256: x 123
    // 1: address: addr 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 2: uint256[]: arr 1,2
    // 3: tuple(string,uint256[2]): myStruct hank,3,4