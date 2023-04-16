// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// 當使用 contract 去呼叫另一個 contract 會傳甚麼資料？
// 例如當呼叫以下 Receiver contract 的 transfer function ，正在傳甚麼資料？
//     把資料存入 event 以方便看交易實際上是傳甚麼資料。

contract Receiver {
    event Log(bytes data);
    function transfer(address _to, uint _amount) external {
        emit Log(msg.data);
        // 部署執行後，可以在 logs 查看 data 欄位值。
        // 0xa9059cbb0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000000000000000000000000000000000000000000b
        // 說明如何將呼叫的 function 及其參數編碼成上面的樣子
        // - 0xa9059cbb - function selector (前面 4 bytes) = 呼叫的 function
        //   EVM 如何知道是與 transfer(address _to, uint _amount) 有關？
        //   就是把 function signature 進行 hash ， 然後提取前面 4 bytes 的值。 => 參考以下 FunctionSelector contract 。
        // - 其他的資料 = 傳入的參數
        //   - 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc
        //     傳入的 address 參數值
        //   - 4000000000000000000000000000000000000000000000000000000000000000b
        //     傳入的 amount 參數值 ( uint 會被編碼成 hex ， decode 就會是 11 )

    }
}

contract FunctionSelector {
    // 傳入 function signature - "transfer(address,uint256)"
    //     注意： function signature 只需要
    //             - functionName(parameterDataType)
    //             - 不可有空格
    //             - uint 需標示清楚原本的預設值 uint256
    // 回傳 function selector - 4 bytes 
    function getSelector(string calldata _func) external pure returns (bytes4) {
        // 因為 keccak256 傳入參數為 bytes 所以需要轉型成 bytes
        return bytes4(keccak256(bytes(_func)));
    }
}