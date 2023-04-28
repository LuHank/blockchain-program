// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter-init.sol";

contract CounterTest is Test {
    CounterInit public counter;

    function setUp() public {
        // 執行前第一個呼叫的 function
        counter = new CounterInit(); // 建立 Counter contract's instance
        counter.setNumber(0); // 初始值
    }

    function testIncrement() public {
        counter.increment(); // 呼叫要測試合約的 function
        assertEq(counter.number(), 1); // 檢查 increment function 的結果是否有真的加 1
    }

    function testSetNumber(uint256 x) public {
        counter.setNumber(x); // 呼叫要測試合約的 function
        assertEq(counter.number(), x); // 檢查 setNumber function 結果是否正確
    }
}
