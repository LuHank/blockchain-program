pragma solidity ^0.8.9;

// mint BAYC test case 重新 mint BAYC 情境

import "forge-std/Test.sol"; // lib/forge-std/src/Test.sol

interface IBoredApeYachtClubInterface {
    function mintApe(uint numberOfTokens) public payable;
}

contract MyContractTest3 is Test {
    
    function setUp() public {
        address user = address(1);
    }

    function testCreateFork() {
        uint256 forkId = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/ZR1nYeq_EaYTkkDe_EivFWzJPbOrvEkV", 12299047);
        vm.selectFork(forkId);

        assertEq(block.number, 12299047);

    }
    // vm.deal 至少要有 8 ETH
    // mint 需要合約地址, user

    function testMint() external {
        vm.deal(user, 8);
        address baycAddress = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
        IBoredApeYachtClubInterface bayc = IBoredApeYachtClubInterface(baycAddress);
        vm.prank(user);
        for (uint n = 0; n < 5; n++ ) {
            bayc.mintApe(20);
        }
        assertEq(bayc.balanceOf(user), 100);
    }

  
}