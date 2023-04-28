// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {MyToken} from "../src/Imports.sol";
import "forge-std/console.sol";

contract ImportsTest is Test {
    MyToken public myToken;
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        myToken = new MyToken();
    }

    function testERC20EmitsTransfer() public {
        vm.deal(msg.sender, 10);
        console.log("msg.sender.balance:", msg.sender.balance);
        console.log("address(this).balance:", address(this).balance);
        console.log("msg.sender:", msg.sender);
        console.log("address(this):", address(this));
        myToken.mint(address(this), 10);
        console.logUint(myToken.balanceOf(address(this)));
        // console.logUint(MyToken.totalSupply);
        // Only `from` and `to` are indexed in ERC20's `Transfer` event,
        // so we specifically check topics 1 and 2 (topic 0 is always checked by default),
        // as well as the data (`amount`).
        // vm.expectEmit(true, true, false, true);
        vm.expectEmit(true, true, false, true, address(myToken));

        // We emit the event we expect to see.
        emit ImportsTest.Transfer(address(this), address(1), 10);

        // We perform the call.
        myToken.transfer(address(1), 10);
    }
}