// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";
import "forge-std/console.sol";

contract AuthTest is Test {
    Wallet public wallet;

    function setUp() public {
        // deploy Wallet contract
        wallet = new Wallet();
    }
    // test 修改 owner 成功
    function testSetOwner() public {
        // 因為是 AuthTest contract 部署 Wallet contract
        // 所以 AuthTest contract 是 owner
        wallet.setOwner(address(1));
        assertEq(wallet.owner(), address(1));
    }
    // test 呼叫合約的必須是 owner 否則失敗
    function testFailSetOwner() public {
        console.log("wallet owner is:", msg.sender);
        // 告訴 Foundry 下一行執行的 msg.sender 是 address(1)
        // 但實際上執行下一行的是 AuthTest contract
        vm.prank(address(1));
        wallet.setOwner(address(1));
    }

    function testFailSetOwneAgain() public {
        // msg.sender = address(this)
        // address(this) 代表這個合約，也就是 AuthTest contract
        wallet.setOwner(address(1));

        // 告訴 Foundry 接下來執行的 msg.sender 都會設定為 address(1)
        vm.startPrank(address(1));
        
        // msg.sender = address(1)
        wallet.setOwner(address(1));
        wallet.setOwner(address(1));
        wallet.setOwner(address(1));

        vm.stopPrank();

        // 因為 wallet.setOwner(address(1)); 已經把 owner 改為 address(1)
        // 所以這一行會 fail 
        // 又因為我們告訴 Foundry 此 function 為 testFail 代表會預期此 function 會 fail
        // 所以 test pass
        // 如果把這一行拿掉，則 test 會 fail ，因為預期會 testFail 。
        // 如果把這一行拿掉且 function name 移除 Fail 則會 test pass
        // msg.sender = address(this)
        wallet.setOwner(address(1));

    }
}