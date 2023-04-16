// SPDX-Licens-Identifier: MIT
pragma solidity ^0.8.3;

// 3 ways to send ETH
// transfer - 2300 gas, reverts (如果某些原因失敗則整個 function 都會失敗)
// send - 2300 gas, return bool (與 transfer 不同的是會回傳 true or false 顯示成功或失敗)
// call - all gas, returns bool adn data (一樣會回傳 true or false 顯示成功或失敗以及一些 data )

// 要能夠讓合約 send ether 則必須讓合約能夠 receive ether
// 1. payable constructor (部署時 send ether )
// 2. payable fallback function or payable receive function (呼叫 payable function to send ether )
//    若只有 payable receive function 而沒有 payable fallback function 
//    代表若嘗試呼叫合約沒有的 function 由於我們沒有 fallback function ，則你呼叫的 function 會失敗。

// 從合約把 ether 傳出來

// 從 SendEther contract 傳 ether 給 EthReceiver contract

contract SendEther {
    constructor() payable {

    }

    receive() external payable {

    }

    // 從合約把 ether 傳出來
    // 以下三種方法就是從此合約傳 ether 給 EthReceiver contract ， 所以 _to 需傳入 EthReceiver contract address 。
    function sendViaTransfer(address payable _to) external payable {
        _to.transfer(123); // 123 wei
    }

    // 大部分主鏈都不使用 send() ，而寧願使用 transfer() 或者 call() 。
    function sendViaSend(address payable _to) external payable {
        bool sent = _to.send(123);
        require(sent, "send failed");
    }

    function sendViaCall(address payable _to) external payable {
        // (bool success, bytes memory data) = _to.call{value: 123}("");
        // 目前先忽略 data ，之後會再詳細介紹 call()
        (bool success, ) = _to.call{value: 123}("");
        require(success, "call failed");
    }
}

contract EthReceiver {
    event Log(uint amount, uint gas);
    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}

// 部署與執行
// 1. deploy 
//    - SendEther contract with msg.value = 1 ether 
//    - EthReceiver contract wihout msg.value = 0 ether
// 2. 呼叫 SendEther contract function
//    - sendViaTransfer(EthReceiver contract address)
//      gas = 2260
//    - sendViaSend(EthReceiver contract address) 
//      gas = 2260
//    - sendViaCall(EthReceiver contract address)
//      gas = 6229 (影片竟然有 78719075 ， Remix VM 由 Merge 改選擇 London ，也是只有 6229 )

// conclusion:
//    建議使用 transfer() 比較便宜，但從來沒看過使用 send() 。