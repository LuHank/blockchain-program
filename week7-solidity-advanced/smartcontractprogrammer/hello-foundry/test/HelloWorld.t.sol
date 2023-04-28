// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld public helloworld;

    function setUp() public {
        // 執行前第一個呼叫的 function
        helloworld = new HelloWorld(); // 建立 Counter contract's instance
    }

    function testGreet() public {
        assertEq(helloworld.greet(), "Hello World");
    }
}
