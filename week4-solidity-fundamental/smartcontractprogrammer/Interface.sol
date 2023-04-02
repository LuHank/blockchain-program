// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// interface: 不需要別的合約程式碼(有可能別人的合約程式碼有上千行)，就可呼叫別的合約。
// 慣例： interface 名稱第一個字母為大寫 I 。

// 有可能上千行，總不能全部複製過來，會造成原本自己的合約程式碼不易閱讀。
// contract Counter {
//     uint public count;

//     function inc() external {
//         count += 1;
//     }

//     function dec() external {
//         count -= 1;
//     }
// }

interface ICounter {
    // getter function - https://docs.soliditylang.org/en/develop/contracts.html#getter-functions
    // public state variable's getter function - function name 要跟 Counter state variable 同樣名稱，否則會報錯。
    function count() external view returns(uint);
    // public state variable's getter function - 接收 Counter 有 2 個以上的 state variable 。
    function acount() external view returns(uint);
    function inc() external;
}

contract CallInterface {
    uint public counter;
    uint public acounter;

    // 傳入 Counter contract address
    function examples(address _counter) external {
        // Counter(_counter).inc();
        ICounter(_counter).inc();
        counter = ICounter(_counter).count(); // state variable 儲存回傳的 current count 。
        acounter = ICounter(_counter).acount();
    }
}