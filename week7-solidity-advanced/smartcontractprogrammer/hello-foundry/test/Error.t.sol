// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Error} from "../src/Error.sol";

contract ErrorTest is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }
    // testFail 告訴 Foundry 裡面的程式碼預期會丟出 error
    function testFail() public {
        // 因為 throwError() 判斷需要 false 否則會丟 error 但初始為 true 所以一定會丟 error
        err.throwError();
    }

    // 也可以取名為 testRevert 告訴 Foundry 裡面程式碼會被 revert
    // 但須增加 vm.expectRevert(); 期望下一行會出現 revert
    function testRevert() public {
        vm.expectRevert();
        err.throwError();
    }

    // 測試 require 會丟出預期的錯誤訊息
    function testRequireMessage() public {
        vm.expectRevert(bytes("not authorized"));
        err.throwError();
    }
    // test custom error
    // vm.expectRevert(contract.function.selector);
    function testCustomError() public {
        vm.expectRevert(Error.NotAuthorized.selector);
        err.throwCustomError();
    }
    // 假設有非常多 assertions
    function testErrorLabel() public {
        assertEq(uint256(1), uint256(1), "test 1");
        assertEq(uint256(1), uint256(1), "test 2");
        assertEq(uint256(1), uint256(1), "test 3");
        // assertion will fail ，但如果沒做 label ，forge test -vvv 很難看出來是哪一個 assertion fail 。
        assertEq(uint256(1), uint256(2), "test 4");
        assertEq(uint256(1), uint256(1), "test 5");
    }
}