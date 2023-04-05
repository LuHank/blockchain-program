// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Visibility: 合約或者其他合約存取 state variable 或者 function 的權限
// private - only inside contract
// internal - only inside contract and child contracts
// public - inside and outside contract
// external - only from outside contract or account that are external to this contract

/*
___________________
| A                |
| private pri()    |
| internal inter() |
| public pub()     | <----------- C
| external ext()   |    pub() and ext()
___________________

B is child contract of A
___________________
| B is A           | <----------- C
| inter()          |    pub() and ext()
| pub()            |
___________________
*/

contract VisibilityBase {
    uint private x = 0;
    uint internal y = 1;
    uint public z = 2;

    function privateFunc() private pure returns (uint) {
        return 0;
    }

    function internalFunc() internal pure returns (uint) {
        return 100;
    }

    function publicFunc() public pure returns (uint) {
        return 200;
    }

    function externalFunc() external pure returns (uint) {
        return 300;
    }

    // 列出可以存取或者呼叫的 state variables or function
    function examples() external view {
        x + y + z;

        privateFunc();
        internalFunc();
        publicFunc();
        // 編譯錯誤： undeclared identifier
        // externalFunc();
        // hack tricky: 加上前綴 this - 在此合約做一個 external call (就像被其他合約呼叫除了只是在此合約呼叫)
        // 但花費的 gas 會比較沒有效率比較高
        // this.externalFunc();
    }
}

// 列出可以存取或者呼叫的 state variables or function
contract VisibilityChild is VisibilityBase {
    function examples2() external view {
        // 編譯錯誤： undeclared identifier
        // x + y + z;

        y + z;

        // // 編譯錯誤： undeclared identifier
        // privateFunc();

        internalFunc();
        publicFunc();

        // 編譯錯誤： undeclared identifier
        // externalFunc();
        // 因為 child contract 就像 parent contract 在 contract 內宣告 external Func()

    }
}