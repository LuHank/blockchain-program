// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// call multiple functions or call multiple contracts
// multicall query into a single function call - 兩個 block.timestamp 就會一樣了。 

contract TestMultiCall {
    function func1() external view returns (uint, uint) {
        return (1, block.timestamp);
    }

    function func2() external view returns (uint, uint) {
        return (2, block.timestamp);
    }

    function getData1() external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.func1.selector);
    }

    function getData2() external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.func2.selector);
    }
}
// targets 放 2 次 contract address
//   ["0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005","0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005"]
// data 放 func1, func2 的 function selector
//   ["0x74135154","0xb1ade4db"]
contract MultiCall {
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "target length != data length");
        bytes[] memory results = new bytes[](data.length);

        for (uint i; i < targets.length; i++) {
            // 這裡使用 staticcall 是因為只會 query 資料所以 function 宣告為 view 不修改區塊鏈資料
            // 若使用 call 則須把 view 移除改成會修改區塊鏈資料 modifier
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "staticcall failed");
            results[i] = result;
        }

        return results;
    }
}

// results
// 0x0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000006447d2ac,0x0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000006447d2ac
// func1 outputs - 1
//   0x0000000000000000000000000000000000000000000000000000000000000001
// func1 outputs - timestamp
//   00000000000000000000000000000000000000000000000000000006447d2ac
// func2 outputs - 2
//   0x0000000000000000000000000000000000000000000000000000000000000002
// func2 outputs - timestamp
//   000000000000000000000000000000000000000000000000000000006447d2ac
// 注意：兩個 timestamp 會一樣。