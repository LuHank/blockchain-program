// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import {Weth9} from "../src/Weth9.sol";
import "forge-std/console.sol";

contract Weth9Test is Test {
    Weth9 public weth9;
    address public user1 = address(123);
    address public user2 = address(456);
    address public user3 = address(789);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Withdraw(address indexed from, address indexed to, uint value);
    event Log(string func, address sender, uint value, bytes data);

    // vm.deal(user1, 5);

    function setUp() public {
        // 需部署的時候就存入 9 ether 以及 token's totalSupply
        // 需要 ether 是因為若使用者要提領則需退回相對應數量的 ether
        weth9 = new Weth9 {value: 9 ether}(10000000000000000000000000000);
    }

    // test deposit
    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function testDepositBalanceOf() public {
        // forge test 4 個 v 以上才會顯示 label - vm.label(user1, "jack");
        vm.label(user1, "alice");
        // depost 是依據使用者存入的 ether 換取相對應數量的 token
        // 所以一開始使用者須有 ether
        vm.deal(user1, 100); // 改變 user1 的 ether 餘額
        console.logUint(user1.balance);
        console.logUint(weth9.balanceOf(user1));
        console.logUint(address(weth9).balance);
        uint amount = 10;
        uint beforeBalance = weth9.balanceOf(user1);
        // 需要修改 msg.sender = user 否則 msg.sender 會是 test contract 。
        // 沒這行， weth9.balanceOf(user1); 永遠會是 0
        vm.prank(user1); 
        weth9.deposit{value:amount}();
        // weth9.deposit.value(amount)(); // deprecated
        uint afterBalance = weth9.balanceOf(user1);
        console.logUint(user1.balance);
        console.logUint(weth9.balanceOf(user1));
        assertEq((afterBalance - beforeBalance), amount);
    }
    // testFail 代表若有錯誤則 test pass
    // 因為沒加 vm.prank(user1) 所以 msg.sender 為 Weth9Test contract
    function testFailDepositBalanceOf() public {
        vm.label(user1, "alice");
        vm.deal(user1, 100);
        uint amount = 10;
        uint beforeBalance = weth9.balanceOf(user1);
        // vm.prank(user1); 
        weth9.deposit{value:amount}();
        // weth9.deposit.value(amount)(); // deprecated
        uint afterBalance = weth9.balanceOf(user1);
        assertEq((afterBalance - beforeBalance), amount);
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function testDepositEther() public {
        vm.deal(user1, 100);
        console.logUint(user1.balance);
        console.logUint(address(weth9).balance);
        uint amount = 10;
        uint beforeBalance = address(weth9).balance;
        uint beforeUserBalance = user1.balance;
        // 需要修改 msg.sender = user 否則 msg.sender 會是 test contract 。
        // 沒這行， weth9.balanceOf(user1); 永遠會是 0
        vm.prank(user1); 
        weth9.deposit{value:amount}();
        // weth9.deposit.value(amount)(); // deprecated
        uint afterBalance = address(weth9).balance;
        uint afterUserBalance = user1.balance;
        console.logUint(user1.balance);
        console.logUint(address(weth9).balance);
        assertEq((afterBalance - beforeBalance), amount);
        assertEq((beforeUserBalance - afterUserBalance), amount);
    }

    // 測項 3: deposit 應該要 emit Deposit event
    function testDepositEvent() public {
        // 1. Tell Fundry which data to check
        vm.expectEmit(true, true, false, true);
        // 2. Emit the expected event - we expect to receive
        emit Transfer(address(0), address(this), 10);
        // 3. Call the actual function that should emit the event
        weth9.deposit{value:10}();
    }

    // test withdraw
    // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function testWithdrawBurn() public {
        uint beforeWeth9TotalSupply = weth9.totalSupply();
        vm.deal(user1, 10);
        vm.startPrank(user1);
        weth9.deposit{value:10}();
        console.logUint(weth9.balanceOf(user1));
        console.logUint(weth9.totalSupply());
        uint beforeBalanceOfUser1 = weth9.balanceOf(user1);
        uint amount = 3;
        weth9.withdraw(amount);
        vm.stopPrank();
        console.logUint(weth9.balanceOf(user1));
        console.logUint(weth9.totalSupply());
        uint afterBalanceOfUser1 = weth9.balanceOf(user1);
        uint afterWeth9TotalSupply = weth9.totalSupply();
        assertEq((beforeWeth9TotalSupply - afterWeth9TotalSupply - afterBalanceOfUser1), amount);
    }

    // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function testWithdrwaEther() public {
        vm.deal(user1, 20);
        console.logUint(user1.balance);
        vm.startPrank(user1);
        weth9.deposit{value:8}();
        console.logUint(user1.balance); // 買 10 token 所以會變為 12
        uint beforeBalance = user1.balance; // 12
        uint amount = 3;
        weth9.withdraw(amount);
        vm.stopPrank();
        console.logUint(user1.balance); // withdraw 3 token 所以會變為 15
        uint afterBalance = user1.balance; // 15
        assertEq((afterBalance - beforeBalance), amount);
    }

    // 測項 6: withdraw 應該要 emit Withdraw event
    function testWithdrawEvent() public {
        // 1. Tell Fundry which data to check
        // 2. Emit the expected event - we expect to receive
        // 3. Call the actual function that should emit the event

        vm.deal(user1, 10);
        vm.startPrank(user1);
        weth9.deposit{value:10}();
        vm.expectEmit(true, true, false, true);
        emit Withdraw(user1, address(0), 10);
        weth9.withdraw(10);
    }

    // test transfer
    // 測項 7: transfer 應該要將 erc20 token 轉給別人
    function testTransferToken() public {
        vm.deal(user1, 20);
        vm.startPrank(user1);
        uint amount = 8;
        weth9.deposit{value:10}();
        console.logUint(weth9.balanceOf(user1)); // 10 
        console.logUint(weth9.balanceOf(user2)); // 0
        weth9.transfer(user2, amount);
        vm.stopPrank();
        console.logUint(weth9.balanceOf(user1)); // 2 
        console.logUint(weth9.balanceOf(user2)); // 8
        assertEq(weth9.balanceOf(user2), amount);
    }
    // 測試 transfer 是否會觸發 Transfer event
    function testTransferEvent() public {
        vm.deal(user1, 20);
        vm.startPrank(user1);
        weth9.deposit{value:10}();
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user2, 10);
        weth9.transfer(user2, 10);
        vm.stopPrank();
    }

    // test approve
    // 測項 8: approve 應該要給他人 allowance
    function testApprove() public {
        vm.startPrank(user1);
        vm.deal(user1, 200);
        weth9.deposit{value:100}();
        weth9.approve(user2, 10);
        assertEq(weth9.allowance(user1, user2), 10);
        vm.stopPrank();
        // 放在這裡也沒問題，因為誰去讀取 allowance 結果都一樣。
        assertEq(weth9.allowance(user1, user2), 10);
    }
    // 測試 approve function 是否有觸發 Approval event
    function testApproveEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(address(this), user2, 10);
        weth9.approve(user2, 10);
    }
    // 測試 approve function 是否有觸發 Approval event
    // 且只檢查第 1 個 index
    function testApproveEventFirstIndex() public {
        vm.expectEmit(true, false, false, false);
        emit Approval(address(this), user2, 10);
        weth9.approve(user3, 20);
    }

    // transferFrom
    // 測項 9: transferFrom 應該要可以使用他人的 allowance
    function testTransferFromAllownace() public {
        vm.startPrank(user1);
        vm.deal(user1, 200);
        weth9.deposit{value:100}();
        weth9.approve(user2, 20);
        vm.stopPrank();
        // 判斷 user2 具有 user1 給予的 allowance
        vm.prank(user2);
        weth9.transferFrom(user1, user3, 10);
        // 判斷 test contract 未具有 user1 給予的 allowance
        // 因為 msg.sender 沒有改成 user2
        vm.expectRevert(stdError.arithmeticError);
        weth9.transferFrom(user1, user3, 10);
    }

    // 測項 10: transferFrom 後應該要減除用完的 allowance
    function testTransferFromRemoveAllownace() public {
        vm.startPrank(user1);
        vm.deal(user1, 200);
        weth9.deposit{value:100}();
        weth9.approve(user2, 10);
        vm.stopPrank();
        vm.prank(user2);
        weth9.transferFrom(user1, user3, 10);
        assertEq(weth9.allowance(user1, user2), 0);
    }
    // 測試 transferFrom 是否有觸發 Transfer event
    function testTransferFromEvent() public {
        // forge test 4 個 v 以上才會顯示 label - vm.label(user1, "jack");
        vm.label(user1, "jack");
        vm.label(user2, "bill");
        vm.label(user3, "hank");
        vm.deal(user1, 30);
        vm.startPrank(user1);
        weth9.deposit{value:20}();
        weth9.approve(user2, 10);
        vm.stopPrank();
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user3, 10);
        vm.prank(user2);
        weth9.transferFrom(user1, user3, 10);
    }

    // 測試傳 ether 給 Weth9 contract 是否會觸發 receive's event
    function testReceiveEvent() public {
        vm.deal(user1, 10);
        vm.expectEmit(false, false, false, true);
        emit Log("receive", user1, 10, "");
        vm.prank(user1);
        address(weth9).call{value:10}("");
    }

    // mint
    // 測試 mint 是否有增加 Weth9 合約的 totalSupply
    // 發現這裡不需要 ether 就可以 mint ，未來需修改。
    function testMintTotalSupply() public {
        console.logUint(weth9.totalSupply());
        uint beforeTotalSupply = weth9.totalSupply();
        uint amount = 99;
        weth9.mint(amount);
        console.logUint(weth9.totalSupply());
        uint afterTotalSupply = weth9.totalSupply();
        assertEq((afterTotalSupply - beforeTotalSupply), amount);
    }

    // 測試 mint 只允許 owner 才可以執行
    function testMintOwner() public {
        // owner 可 mint
        // owner = test contract
        // 因為一開始部署 Weth9 是 test contract
        // 可參考 setUp() - new Weth9()
        weth9.mint(10);

        // 不是 owner 不可 mint
        // 因為一開始部署 Weth9 contract 的是 test contract 而不是 user1
        vm.expectRevert(bytes("not authorized"));
        vm.prank(user1);
        weth9.mint(10);
    }

    // 測試 mint 是否有觸發 Transfer event
    function testMintEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), address(this), 10);
        weth9.mint(10);
    }
}