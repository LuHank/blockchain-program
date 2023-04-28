// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
import "forge-std/console.sol";

contract CounterTest is
    Test // 每次執行 test 前就會被執行
{
    Counter public counter;

    function setUp() public {
        counter = new Counter(); // deploy a new Counter contract
    }

    function testLogSomething() public {
        console.log("Log Somthing Here", 123);
        // 如果想要顯示 int
        int x = -1;
        console.logInt(x);
    }

    // 必須是 public or external
    // function name prefix 必須是 test
    function testInc() public {
        counter.inc();
        assertEq(counter.count(), 1);
        // test fail
        // [FAIL. Reason: Assertion failed.] testInc() (gas: 43673)
        // Logs:
        // Error: a == b not satisfied [uint]
        //         Left: 1
        //     Right: 2
        // assertEq(counter.count(), 2);
    }

    // fail function 兩種寫法
    // 1. 預期會 fail 則 function name prefix 必須是 testFail
    // 呼叫其他 function 前，先呼叫 dec() 會造成 underflow error
    function testFailDec() public {
        counter.dec();
        // 以下不會 fail 所以在這裡會報錯 test fail
        // counter.inc();
    }
    //2. 指名哪種錯誤
    function testDecUnderflow() public {
        // 期待下一行程式碼會發生四則運算錯誤
        vm.expectRevert(stdError.arithmeticError);
        counter.dec();
    }

    function testDec() public {
        counter.inc();
        counter.inc();
        counter.dec();
        assertEq(counter.count(), 1);
    }
}
