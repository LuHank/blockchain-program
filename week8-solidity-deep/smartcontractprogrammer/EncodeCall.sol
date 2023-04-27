// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// 3 種 encode data 方法且 data 將 pass the loadable function to call the other contracts
// outputs 都會相同
// - encodeWithSignature
// - encodeWithSelector
// - encodeCall
// 呼叫 test function 然後使用 low-level function call - Token contract 傳入 data (藉由以上方法 return)
// 使用 test function 呼叫 Token contract transfer function 將錢轉給 AbiEncode contract

interface IERC20 {
    function transfer(address, uint) external;
}

contract Token {
    function transfer(address, uint) external {}
}

contract AbiEncode {
    function test(address _contract, bytes calldata data) external {
        (bool ok,) = _contract.call(data);
        require(ok, "call failed");
    }
    // 如果 function signature 寫錯仍然可以編譯但交易會失敗 - 例如多一個空格或者 uint
    function encodeWithSignature(address to, uint amount)
        external
        pure
        returns(bytes memory)
    {
        // uint 須明確指定為 uint256
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }
    // 如果 function 寫錯會編譯錯誤
    // 但若參數錯誤則編譯會過但交易會失敗
    function ecdoeWithSelector(address to, uint amount)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    // 此方法則是要 function name 及參數都要全部對才能編譯成功
    function encdoeCall(address to, uint amount) external pure returns (bytes memory) {
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}

// 執行
// AbiEncode contract
//  三種 function 皆輸入 AbiEncode contract address, 123
//  得到的結果會是一樣
// AbiEncode contract
//  test function 輸入 Token contract address, 上面的結果 => 代表使用 test function 呼叫 Token contract transfer function 將錢轉給 AbiEncode contract