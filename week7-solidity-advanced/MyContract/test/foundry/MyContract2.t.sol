pragma solidity ^0.8.9;

import "forge-std/Test.sol"; // lib/forge-std/src/Test.sol
import { TestPractice } from "../../contracts/MyContract2.sol";

contract MyContractTest2 is Test {
    TestPractice instance;
    address user1;
    address user2;

    function setUp() public {
    // 1. Set user1, user2 
    user1 = 0x7Fd8FdD7C6E1DC00D29776AF21F0D78D63d8384d;
    user2 = 0x7Fd8FdD7C6E1DC00D29776AF21F0D78D63d8384d;
    // 2. Create a new instance of MyContract
    instance = new TestPractice(user1, user2);
    // 3. (optional) label user1 as bob, user2 as alice
    vm.label(user1, "bob");
    vm.label(user2, "alice");
  }

  function testSendEther(address _user1, address _user2) external {
    // vm.startPrank(_user1);
    // vm.startPrank(_user2);
    if (_user1 != user1 && _user2 != user2) {
        vm.expectRevert();
        instance.sendEther(_user2, 1);
    }

    // vm.stopPrank(_user1);
    // vm.stopPrank(_user2);
  }

  function testBalance() external {
    
    instance.sendEther(user2, 10);
  }
}