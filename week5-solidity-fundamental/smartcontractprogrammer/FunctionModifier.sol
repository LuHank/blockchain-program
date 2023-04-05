// SPDX-Licentse-Identifier: MIT
pragma solidity ^0.8.7;

// Function modifier: reuse code before and / or after function
// Basic, inputs, sandwich
// function modifier: 可以允許你重複使用程式碼。 (使用一個地方的程式碼然後重複使用此程式碼邏輯)

contract FunctionModifier {
    bool public paused;
    uint public count;

    function setPause(bool _paused) external {
        paused = _paused;
    }

    modifier whenNotPaused() {
        require(!paused, "paused");
        _; // 告訴 solidity ，實際 function 調用此 modifier function 來修飾包裝自己。回去執行主要實際 function 。
        // 實際使用：在實際 function signature 宣告 modifier function 。
    }

    // basic
    function inc() external whenNotPaused {
        // require(!paused, "paused"); // 合約沒有被暫停的時候才能呼叫。
        count += 1;
    }

    function dec() external whenNotPaused {
        // require(!paused, "paused"); // 重複一樣的程式碼邏輯
        count -= 1;
    }

    // inputs - 將 inputs 傳入 modifier function
    modifier cap(uint _x) {
        require(_x < 100, "x >= 100");
        _;
    }

    function incBy(uint _x) external whenNotPaused cap(_x) {
        // require(_x < 100, "x >= 100");
        count += _x;
    }

    // sandwich - modifier function that sandwishes a function
    // 執行步驟
    // 1. 呼叫 foo()
    // 2. 執行 modifier function - sandwich: count += 10;
    // 3. 遇到 _; 回去執行 foo()
    // 4. count += 1;
    // 5. 執行完 foo() 回到 modifier function 繼續執行 _; 之後的程式碼
    // 6. count *= 2
    modifier sandwich() {
        // code here
        count += 10;
        _;
        count *= 2;
    }

    function foo() external sandwich {
        count += 1;
    }
}