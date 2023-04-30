// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.6.12;

// 0.8.17 改成 0.6.12 就需要以下這行
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { FiatTokenV3 } from "../src/FiatTokenV3.sol";

interface IFiatTokenProxy {
    function balanceOf(address account) external view returns (uint256);
    function upgradeTo(address newImplementation) external;
    function implementation() external view;
    function getBlacklister() external;
}

contract FiatTokenProxyTest is Test {
    address usdc_owner = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a;
    address usdc_admin = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
    address fiatTokenProxyAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address initWhiteList = address(1);
    address whiteListUser;
    address notWhiteListUser = makeAddr("notWhiteListUser");
    IFiatTokenProxy iFiatTokenProxy = IFiatTokenProxy(fiatTokenProxyAddress);
    FiatTokenV3 implementatoinFiatTokenV3; 
    FiatTokenV3 proxyFiatTokenV3;

    function setUp() public {
        uint256 forkId = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/ZR1nYeq_EaYTkkDe_EivFWzJPbOrvEkV");
        vm.selectFork(forkId);
        vm.startPrank(usdc_admin);
        // vm.deal(usdc_admin, 8);
        implementatoinFiatTokenV3 = new FiatTokenV3();
        iFiatTokenProxy.upgradeTo(address(implementatoinFiatTokenV3));
        proxyFiatTokenV3 = FiatTokenV3(address(iFiatTokenProxy));
        vm.stopPrank();
        // console.log(iFiatTokenProxy.implementation());
    }

    function testProxyOfMainnet() public {
        vm.startPrank(usdc_owner);
        uint256 ownerBalance = iFiatTokenProxy.balanceOf(usdc_owner);
        console.log(ownerBalance);
        vm.stopPrank();
        assertEq(ownerBalance > 0, true);
    }

    function testWhiteList() public {
        vm.startPrank(usdc_owner);
        proxyFiatTokenV3.updateWhitelister(address(1));
        address w = proxyFiatTokenV3.whitelister();
        console.log(w);
        vm.stopPrank();
        assertEq(initWhiteList, w);
    }

    function testAllowMint() public {
        vm.startPrank(usdc_owner);
        proxyFiatTokenV3.updateWhitelister(address(1));
        whiteListUser = proxyFiatTokenV3.whitelister();
        vm.deal(whiteListUser, 10);
        uint256 mintAmount = 10;
        uint256 beforeBalanceOf = proxyFiatTokenV3.balanceOf(whiteListUser);
        proxyFiatTokenV3.updateMasterMinter(whiteListUser);
        vm.stopPrank();
        vm.startPrank(whiteListUser);
        proxyFiatTokenV3.configureMinter(whiteListUser, mintAmount); 
        proxyFiatTokenV3.mint(whiteListUser, mintAmount);
        vm.stopPrank();
        vm.prank(usdc_owner);
        uint256 afterBalanceOf = proxyFiatTokenV3.balanceOf(whiteListUser);
        assertEq((afterBalanceOf - beforeBalanceOf), mintAmount);
    }

    function testFuzzAllowMint(uint96 amount) public {
        vm.assume(amount > 0);
        vm.startPrank(usdc_owner);
        proxyFiatTokenV3.updateWhitelister(address(1));
        whiteListUser = proxyFiatTokenV3.whitelister();
        vm.deal(whiteListUser, amount);
        uint256 beforeBalanceOf = proxyFiatTokenV3.balanceOf(whiteListUser);
        proxyFiatTokenV3.updateMasterMinter(whiteListUser);
        vm.stopPrank();
        vm.startPrank(whiteListUser);
        proxyFiatTokenV3.configureMinter(whiteListUser, amount); 
        proxyFiatTokenV3.mint(whiteListUser, amount);
        vm.stopPrank();
        vm.prank(usdc_owner);
        uint256 afterBalanceOf = proxyFiatTokenV3.balanceOf(whiteListUser);
        assertEq((afterBalanceOf - beforeBalanceOf), amount);
    }

    function testAllowTransfer() public {
        vm.startPrank(usdc_owner);
        proxyFiatTokenV3.updateWhitelister(address(1));
        whiteListUser = proxyFiatTokenV3.whitelister();
        vm.deal(whiteListUser, 10);
        uint256 mintAmount = 10;
        proxyFiatTokenV3.updateMasterMinter(whiteListUser);
        vm.stopPrank();
        vm.startPrank(whiteListUser);
        proxyFiatTokenV3.configureMinter(whiteListUser, mintAmount); 
        proxyFiatTokenV3.mint(whiteListUser, mintAmount);
        uint256 transferAmount = 5;
        proxyFiatTokenV3.transfer(notWhiteListUser, transferAmount);
        vm.stopPrank();
        assertEq(proxyFiatTokenV3.balanceOf(notWhiteListUser), transferAmount);
    }

    function testFuzzAllowTransfer(uint96 amount) public {
        vm.assume(amount > 0);
        vm.startPrank(usdc_owner);
        proxyFiatTokenV3.updateWhitelister(address(1));
        whiteListUser = proxyFiatTokenV3.whitelister();
        vm.deal(whiteListUser, amount);
        proxyFiatTokenV3.updateMasterMinter(whiteListUser);
        vm.stopPrank();
        vm.startPrank(whiteListUser);
        proxyFiatTokenV3.configureMinter(whiteListUser, amount); 
        proxyFiatTokenV3.mint(whiteListUser, amount);
        proxyFiatTokenV3.transfer(notWhiteListUser, amount);
        vm.stopPrank();
        assertEq(proxyFiatTokenV3.balanceOf(notWhiteListUser), amount);
    } 
}