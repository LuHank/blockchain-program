// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Event} from "../src/Event.sol";

contract EventTest is Test {
    Event public e;
    // 要與被測試的 event 一模一樣
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        e = new Event();
    }

    function testEmitTransferEvent() public {
        // functon expectEmit(
        //     bool checkTopic1, // 告訴 Founctry 是否應該比較 1st index
        //     bool checkTopic2, // 告訴 Founctry 是否應該比較 2nd index
        //     bool checkTopic3, // 告訴 Founctry 是否應該比較 3rd index
        //     bool CheckData // 告訴 Foundry 是否應該比較其他資料
        // ) external;

        // 1. Tell Fundry which data to check
        //    Check index 1, index2 and data
        // 告訴 Foundry 比較我們將要觸發的 event 與 transfer funtion 觸發的 event
        // 第 3 個 false 代表不需要檢查 3rd index data
        vm.expectEmit(true, true, false, true);

        // 2. Emit the expected event - we expect to receive
        // 我們期望此 event 被觸發，當 step3 執行 function 時。
        emit Transfer(address(this), address(123), 456);

        // 3. Call the actual function that should emit the event
        // if the event emitted in step3 mataches the event emitted in step2 => test pass
        e.transfer(address(this), address(123), 456);

        // 以下會失敗因為 2nd index data 不一樣 (address(124) <> address(123))
        // e.transfer(address(this), address(124), 456);

        // Check index 1
        // 只檢查 1st index datd 所以後面兩個不一樣也會 test pass
        vm.expectEmit(true, false, false, false);
        emit Transfer(address(this), address(123), 456);
        e.transfer(address(this), address(888), 888);
    }

    function testEmitManyTransferEvent() public {
        // prepare function parameters
        address[] memory to = new address[](2);
        to[0] = address(123);
        to[1] = address(456);
        uint256[] memory amount = new uint256[](2);
        amount[0] = 777;
        amount[1] = 888;

        for (uint256 i = 0; i < to.length; i++) {
            // 1. Tell Fundry which data to check
            // 2. Emit the expected event - we expect to receive
            vm.expectEmit(true, true, false, true);
            emit Transfer(address(this), to[i], amount[i]);
        }
        
        // 3. Call the actual function that should emit the event
        e.transferMany(address(this), to, amount);
    }
}