// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// selfdestruct function
// - delete contract
// - force send Ether to any address (EOA, contract address) 強迫將合約內儲存的 Ether 轉到其他 address (清算)
//   就像不須使用 callback function 的合約就可以傳送 ether 給 any address ： 
//   意思是合約不能傳送 ether 給 any address，但是藉由 selfdestruct function 可以強迫將合約內儲存的 ether 傳送 ether 給 any address 。
// 一種可以 hack 其他合約，然後強迫傳送合約內的 ether 給目標 address 。

contract Kill {
    // 合約接收 ehter
    constructor() payable{}

    function kill() external {
        // 因為 msg.sender 要收錢，所以需要用 payable 包起來。
        // msg.sender 呼叫此合約的 EOA or contract address (Helper contract 範例對 Kill contract 而言， Helper contract address 就是 msg.sender )
        selfdestruct(payable(msg.sender));
        // "selfdestruct" has been deprecated. The underlying opcode will eventually undergo breaking changes, 
        // and its use is not recommended.
        // 編譯器 0.8.18 以後就會出現此 warning 。 => 參考 notion 找到的資料 。
    }

    // 展示 selfdestruct 後，合約真的不存在且不能呼叫其 function 。
    // 影片展示會回傳 0 而不是 123 。
    // 但目前會出現 error: Failed to decode output: Error: data out-of-bounds (length=1, offset=32, code=BUFFER_OVERRUN, version=abi/5.5.0)
    // 因為上面解釋 selfdestruct function 已經棄用了。
    function testCall() external pure returns (uint) {
        return 123;
    }
}

// 正常 Helper contract 沒有 fallback function ( payable ) 就不能接收 ether ，但藉由 selfdestruct 就可以不需要 fallback function 接收 ether 。
// fallback function 例如 Kill contract - constructor() payable{}
contract Helper {
    function getBalance() external view returns (uint) {
        // 回傳 Helper contract 餘額
        return address(this).balance;
    }

    // kill function 不是 fallback function (沒有宣告為 payable function ) ，就會把刪除掉合約 ( Kill contract ) 內 ehter 提供給 Helper contract 。
    // 1. deploy Kill contract with 1 Ether
    // 2. deploy Helper contract with 0 Ether
    // 3. call Helper.getBalance(); 結果為 0
    // 4. call Helper.kill(Kill contact address); 會強迫把 Kill contract ether 傳送給 Helper contract 。
    function kill(Kill _kill) external {
        _kill.kill();
    }
}

