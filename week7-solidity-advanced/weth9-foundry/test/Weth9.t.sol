// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import {Weth9} from "../src/Weth9.sol";
import "forge-std/console.sol";

contract Weth9Test is Test {
    Weth9 public weth9;
    // address public user1 = address(123);
    // address public user2 = address(456);
    // address public user3 = address(789);
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Withdraw(address indexed from, address indexed to, uint value);
    event Log(string func, address sender, uint value, bytes data);

    // vm.deal(user1, 5);
    uint amount = 20;
    uint beforeBalance;
    uint afterBalance;
    uint beforeTotalSupplyOfWeth9;

    function setUp() public {
        // 需要 ether 是因為若使用者要提領則需退回相對應數量的 ether
        // 不是一般發幣的 ERC-20 token
        // weth9 = new Weth9 {value: 9 ether}(10000000000000000000000000000);
        weth9 = new Weth9();
        vm.deal(user1, 100);
        beforeBalance = weth9.balanceOf(user1);
        // beforeTotalSupplyOfWeth9 = address(weth9).balance;
        beforeTotalSupplyOfWeth9 = weth9.totalSupply();
        vm.prank(user1); 
        weth9.deposit{value:amount}();
        afterBalance = weth9.balanceOf(user1);
    }

    // test deposit
    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token 提供給 user
    function testDepositBalanceOf() public {
        assertEq((afterBalance - beforeBalance), amount);
    }
    // testFail 代表若有錯誤則 test pass
    // 因為沒加 vm.prank(user2) 所以 msg.sender 為 Weth9Test contract
    function testFailDepositBalanceOf() public {
        weth9.deposit{value:amount}();
        assertEq(weth9.balanceOf(user2), amount);
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function testDepositEther() public {
        uint afterTotalSupplyOfWeth9 = weth9.totalSupply();
        assertEq((afterTotalSupplyOfWeth9 - beforeTotalSupplyOfWeth9), amount);
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
        beforeTotalSupplyOfWeth9 = weth9.totalSupply();
        vm.prank(user1);
        weth9.withdraw(amount);
        // uint afterBalanceOfUser1 = weth9.balanceOf(user1);
        uint afterTotalSupplyOfWeth9 = weth9.totalSupply();
        // assertEq((beforeTotalSupplyOfWeth9 - afterWeth9TotalSupply - afterBalanceOfUser1), amount);
        assertEq((beforeTotalSupplyOfWeth9 - afterTotalSupplyOfWeth9), amount);
    }

    // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function testWithdrwaEther() public {
        console.logUint(user1.balance); // 原本 100 ETH 買 20 WETH 所以會變為 80 ETH
        uint beforeBalanceOfETHOfUser1 = user1.balance;
        amount = 3;
        vm.prank(user1);
        weth9.withdraw(amount);
        console.logUint(user1.balance); // withdraw 3 WETH 所以會變為 83 ETH
        uint afterBalanceOfETHUser1 = user1.balance; // 83 ETH
        assertEq((afterBalanceOfETHUser1 - beforeBalanceOfETHOfUser1), amount); // 83 ETH - 80 ETH = 3 WETH
    }

    // 測項 6: withdraw 應該要 emit Withdraw event
    function testWithdrawEvent() public {
        // 1. Tell Fundry which data to check
        // 2. Emit the expected event - we expect to receive
        // 3. Call the actual function that should emit the event

        vm.expectEmit(true, true, false, true);
        emit Withdraw(user1, address(0), amount);
        vm.prank(user1);
        weth9.withdraw(amount);
    }

    // test transfer
    // 測項 7: transfer 應該要將 erc20 token 轉給別人
    function testTransferToken() public {
        vm.prank(user1);
        weth9.transfer(user2, amount);
        assertEq(weth9.balanceOf(user2), amount);
    }
    // 測試 transfer 是否會觸發 Transfer event
    function testTransferEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user2, amount);
        vm.prank(user1);
        weth9.transfer(user2, amount);
    }

    // test approve
    // 測項 8: approve 應該要給他人 allowance
    function testApprove() public {
        vm.prank(user1);
        weth9.approve(user2, amount);
        assertEq(weth9.allowance(user1, user2), amount);
    }
    // 測試 approve function 是否有觸發 Approval event
    function testApproveEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(user1, user2, amount);
        vm.prank(user1);
        weth9.approve(user2, amount);
    }
    // 測試 approve function 是否有觸發 Approval event
    // 且只檢查第 1 個 index
    function testApproveEventFirstIndex() public {
        vm.expectEmit(true, false, false, false);
        emit Approval(user1, user2, amount);
        vm.prank(user1);
        weth9.approve(user3, amount);
    }

    // transferFrom
    // 測項 9: transferFrom 應該要可以使用他人的 allowance
    function testTransferFromAllownace() public {
        vm.prank(user1);
        weth9.approve(user2, amount);
        // 判斷 user2 具有 user1 給予的 allowance
        vm.prank(user2);
        weth9.transferFrom(user1, user3, amount);
        assertEq(weth9.balanceOf(user3), amount);
    }

    // 測項 10: transferFrom 後應該要減除用完的 allowance
    function testTransferFromRemoveAllownace() public {
        vm.prank(user1);
        weth9.approve(user2, amount);
        vm.prank(user2);
        weth9.transferFrom(user1, user3, amount);
        assertEq(weth9.allowance(user1, user2), 0);
    }
    // 測試 transferFrom 是否有觸發 Transfer event
    function testTransferFromEvent() public {
        vm.prank(user1);
        weth9.approve(user2, amount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user3, 10);
        vm.prank(user2);
        weth9.transferFrom(user1, user3, 10);
    }

    // 測試傳 ether 給 Weth9 contract 是否會觸發 receive's event
    function testReceiveEvent() public {
        // vm.deal(user1, 10);
        vm.expectEmit(false, false, false, true);
        emit Log("receive", user1, 10, "");
        vm.prank(user1);
        address(weth9).call{value:10}("");
    }

    // bchen: WETH 應該是不需要有一個 external mint function 我想，因為他就是要跟 ETH 1比1兌換，如果 owner 可以直接 mint 看起來挺危險
    // mint
    // 測試 mint 是否有增加 Weth9 合約的 totalSupply
    // 發現這裡不需要 ether 就可以 mint ，未來需修改。
    // function testMintTotalSupply() public {
    //     console.logUint(weth9.totalSupply());
    //     uint beforeTotalSupply = weth9.totalSupply();
    //     uint amount = 99;
    //     weth9.mint(amount);
    //     console.logUint(weth9.totalSupply());
    //     uint afterTotalSupply = weth9.totalSupply();
    //     assertEq((afterTotalSupply - beforeTotalSupply), amount);
    // }

    // bchen: WETH 應該是不需要有一個 external mint function 我想，因為他就是要跟 ETH 1比1兌換，如果 owner 可以直接 mint 看起來挺危險
    // 測試 mint 只允許 owner 才可以執行
    // function testMintOwner() public {
    //     // owner 可 mint
    //     // owner = test contract
    //     // 因為一開始部署 Weth9 是 test contract
    //     // 可參考 setUp() - new Weth9()
    //     weth9.mint(10);

    //     // 不是 owner 不可 mint
    //     // 因為一開始部署 Weth9 contract 的是 test contract 而不是 user1
    //     vm.expectRevert(bytes("not authorized"));
    //     vm.prank(user1);
    //     weth9.mint(10);
    // }

    // bchen: WETH 應該是不需要有一個 external mint function 我想，因為他就是要跟 ETH 1比1兌換，如果 owner 可以直接 mint 看起來挺危險
    // 測試 mint 是否有觸發 Transfer event
    // function testMintEvent() public {
    //     vm.expectEmit(true, true, false, true);
    //     emit Transfer(address(0), address(this), 10);
    //     weth9.mint(10);
    // }
}