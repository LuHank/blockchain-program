// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Immutable {
    // immutable state variable 就像常數，除了我們只能設定一次當合約被部署時。
    // 除了部署合約時可以初始化，之後就都不能修改了。所以很多合約都用來在 constructor 初始化 immutable state variable 。
    // 好處： function 使用 state variable 可以節省 gas 。
    address public immutable owner = msg.sender;

    // 就像常數，除了我們只能設定一次當合約被部署時。
    // address public immutable owner; // 初始化
    // constructor() {
    //     owner = msg.sender; // constructor 賦予值
    // }

    uint public x;
    function foo() external {
        require(msg.sender == owner);
        x += 1;
    }
}

// state variable 沒有宣告 immutable 時，呼叫 foo() 的 gas (transaction cost): 45570 gas
// state variable 有宣告 immutable 時，呼叫 foo() 的 gas (transaction cost): 43470 gas