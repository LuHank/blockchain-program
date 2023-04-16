// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
Fallback executed when
- function doesn't exist inside the contract
- 主要使用案例： enable directly send ETH(ether) 或者說能夠讓 smart contract 接收 ether
*/

/*
fallback() or receive() ?
    Ether is send to contract
               |
        is msg.data empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback
*/

contract Fallback {
    event Log(string func, address sender, uint value, bytes data);
    // 1. 當呼叫此合約未存在的 function 例如 foo() ，就會呼叫 fallback() 。
    // 2. 當 EOA 或者 contract 傳 ETH(ether) ，則 fallback() 將會被執行。
    //    為了能夠讓 contract 能夠接收 ether 則需把 fallback() 宣告為 payable。
    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        // 因為當 msg.data 為空時才會執行 reveive() ，所以第三個參數需改為空白。否則會編譯出現 「"msg.data" cannot be used inside of "receive" function.」。 
        emit Log("reveive", msg.sender, msg.value, "");
    }
}

// 注意：部署之後 Remix 是看不到 fallback(), receive() ，但可以藉由 Low Level Interactions - Transact 來呼叫。
// Remix Deploy & run transactions: VALUE = msg.value, Low Level Interactions - CALLDATA = msg.data
/* Remix 執行
   1. VALUE = 1 Ether & CALLDATA = 0X121212 ( 注意： CALLDATA 需為 hex value )
      執行結果：
      - 交易呼叫 Fallback.(fallback)
        [vm]from: 0x5B3...eddC4to: Fallback.(fallback) 0xD7A...F771Bvalue: 1000000000000000000 weidata: 0x121...21212logs: 1hash: 0x323...786af
      - logs
        [
            {
                "from": "0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B",
                "topic": "0xf7f75251dee7d7fc22deac3247729ebe7c86541f35930bf10c2a4207479a3b6c",
                "event": "Log",
                "args": {
                    "0": "fallback",
                    "1": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                    "2": "1000000000000000000",
                    "3": "0x121212",
                    "func": "fallback",
                    "sender": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                    "value": "1000000000000000000",
                    "data": "0x121212"
                }
            }
        ]
      - value: 1000000000000000000 wei ( = 1 Ether )
   2. VALUE = 1 Ether & CALLDATA = 空白
      執行結果：
      - 交易呼叫 Fallback.(receive)
        [vm]from: 0x5B3...eddC4to: Fallback.(receive) 0xD7A...F771Bvalue: 1000000000000000000 weidata: 0xlogs: 1hash: 0xda2...d2246
      - logs:
        [
            {
                "from": "0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B",
                "topic": "0xf7f75251dee7d7fc22deac3247729ebe7c86541f35930bf10c2a4207479a3b6c",
                "event": "Log",
                "args": {
                    "0": "reveive",
                    "1": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                    "2": "1000000000000000000",
                    "3": "0x",
                    "func": "reveive",
                    "sender": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                    "value": "1000000000000000000",
                    "data": "0x"
                }
            }
        ] 
      - value:  1000000000000000000 wei ( = 1 Ether )
   3. VALUE = 1 Ether & CALLDATA = 空白 ( receive function 不存在 )
      執行結果：
      - 交易呼叫 Fallback.(fallback)
        [vm]from: 0x5B3...eddC4to: Fallback.(fallback) 0x358...D5eE3value: 1000000000000000000 weidata: 0xlogs: 1hash: 0x9eb...f1e9e
      - logs:
        [
            {
                "from": "0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3",
                "topic": "0xf7f75251dee7d7fc22deac3247729ebe7c86541f35930bf10c2a4207479a3b6c",
                "event": "Log",
                "args": {
                    "0": "fallback",
                    "1": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                    "2": "1000000000000000000",
                    "3": "0x",
                    "func": "fallback",
                    "sender": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                    "value": "1000000000000000000",
                    "data": "0x"
                }
            }
        ] 
      - value:  1000000000000000000 wei ( = 1 Ether )

*/