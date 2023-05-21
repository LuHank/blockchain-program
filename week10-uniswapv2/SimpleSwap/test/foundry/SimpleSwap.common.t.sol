// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { SimpleSwapSetUp } from "./helper/SimpleSwapSetUp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract SimplwSwapGetterTest is SimpleSwapSetUp {
  function setUp() public override {
    super.setUp();
  }

  function test_getReserve_should_be_able_to_get_Reserve() public {
    uint256 reserveA;
    uint256 reserveB;
    (reserveA, reserveB) = simpleSwap.getReserves();
    assertEq(reserveA, 0);
    assertEq(reserveB, 0);
  }

  function test_getReserve_should_be_able_to_get_reserve_after_add_liquidity() public {
    uint256 reserveA;
    uint256 reserveB;
    uint256 amountA = 100 * 10 ** tokenADecimals;
    uint256 amountB = 100 * 10 ** tokenBDecimals;

    vm.prank(taker);
    simpleSwap.addLiquidity(amountA, amountB);

    (reserveA, reserveB) = simpleSwap.getReserves();
    assertEq(reserveA, amountA);
    assertEq(reserveB, amountB);
    vm.prank(taker);
    simpleSwap.addLiquidity(amountA, amountB);
    (reserveA, reserveB) = simpleSwap.getReserves();
    console.log(reserveA/(10 ** tokenADecimals));
    assertEq(reserveA, amountA * 2);
  }

  function test_getTokenA_should_be_able_to_get_tokenA() public {
    // 檢查 constructor 是否有成功部署 tokenA address
    console.log(simpleSwap.getTokenA());
    assertEq(simpleSwap.getTokenA(), address(tokenA));
  }

  function test_getTokenB_should_be_able_to_get_tokenB() public {
    console.log("tokenB: ", address(tokenB));
    console.log("getTokenB: ", simpleSwap.getTokenB());
    assertEq(simpleSwap.getTokenB(), address(tokenB));
  }
}

contract SimpleSwapLpTokenTest is SimpleSwapSetUp {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function setUp() public override {
    super.setUp();
    uint256 amountA = 100 * 10 ** tokenADecimals;
    uint256 amountB = 100 * 10 ** tokenBDecimals;
    vm.startPrank(maker);
    simpleSwap.addLiquidity(amountA, amountB);
    // uint256(2**256 - 1) 取最大值
    simpleSwap.approve(address(simpleSwap), uint256(2**256 - 1));
    vm.stopPrank();
  }

  function test_lpToken_should_be_able_to_get_lpToken_after_adding_liquidity() public {
    uint256 amountA = 100 * 10 ** tokenADecimals;
    uint256 amountB = 100 * 10 ** tokenBDecimals;
    uint256 liquidity = Math.sqrt(amountA * amountB);

    uint256 makerBalance = simpleSwap.balanceOf(maker);
    vm.startPrank(maker);
    // 參考 week7-smartcontractprogrammer
    // Transfer 應該是沒有 3rd index ?
    vm.expectEmit(true, true, true, true);
    // ERC20's event
    emit Transfer(address(0), maker, liquidity);
    simpleSwap.addLiquidity(amountA, amountB);
    assertEq(simpleSwap.balanceOf(maker), liquidity + makerBalance);
    vm.stopPrank();
  }

  function test_lpToken_should_be_able_to_repay_lptoken_after_removing_liquidity() public {
    uint256 lpTokenAmount = 10 * 10 ** slpDecimals;

    uint256 makerBalance = simpleSwap.balanceOf(maker);
    console.log("makerBalance", makerBalance);
    console.log("lpTokenAmount", lpTokenAmount);
    console.log("before - balance: ", simpleSwap.balanceOf(maker));
    vm.startPrank(maker);
    vm.expectEmit(true, true, true, true);
    emit Transfer(address(simpleSwap), address(0), lpTokenAmount);
    simpleSwap.removeLiquidity(lpTokenAmount);
    console.log("after - balance: ", simpleSwap.balanceOf(maker));
    assertEq(simpleSwap.balanceOf(maker), makerBalance - lpTokenAmount);
    vm.stopPrank();
  }

  function test_lpToken_should_be_able_to_transfer_lp_token() public {
    uint256 lpTokenAmount = 42 * 10 ** slpDecimals;
    vm.startPrank(maker);
    vm.expectEmit(true, true, true, true);
    emit Transfer(maker, taker, lpTokenAmount);
    simpleSwap.transfer(taker, lpTokenAmount);
    vm.stopPrank();
  }

  function test_lpToken_should_be_able_to_approve_lp_token() public {
    uint256 lpTokenAmount = 42 * 10 ** slpDecimals;
    vm.startPrank(maker);
    vm.expectEmit(true, true, true, true);
    emit Approval(maker, taker, lpTokenAmount);
    simpleSwap.approve(taker, lpTokenAmount);
    vm.stopPrank();
  }
}

contract SimpleSwapKValueCheck is SimpleSwapSetUp {

  uint256 K;

  function setUp() public override {
    super.setUp();
    uint256 amountA = 30 * 10 ** tokenADecimals;
    uint256 amountB = 300 * 10 ** tokenBDecimals;
    vm.prank(maker);
    simpleSwap.addLiquidity(amountA, amountB);
    K = amountA * amountB;
  }
  // 測試 rounding 的問題，需要讓他 >= K 
  function test_kValue_should_be_the_greater_after_swaps() public {
    address tokenIn = address(tokenA);
    address tokenOut = address(tokenB);
    uint256 amountIn = 70 * 10 ** tokenADecimals;

    vm.startPrank(taker);
    // 30 * 300 = 9000
    // (30 + 70) * (300 - amountOut) = 9000
    // amount = 300 - 9000/100 = 210
    // 應該是 210 
    // console.log("amountIn: ", amountIn / 10 ** tokenADecimals);
    // (uint aReserve, uint bReserve) = simpleSwap.getReserves();
    // console.log("aReserve0: ", aReserve / 10 ** tokenADecimals);
    // console.log("bReserve0: ", bReserve / 10 ** tokenADecimals);
    // console.log("balanceOfSimpleSwapA0: ", IERC20(tokenIn).balanceOf(address(simpleSwap)) / 10 ** tokenADecimals);
    // console.log("balanceOfSimpleSwapB0: ", IERC20(tokenOut).balanceOf(address(simpleSwap)) / 10 ** tokenBDecimals);

    // uint amountOut = simpleSwap.swap(tokenIn, tokenOut, amountIn);
    // (uint aReserve1, uint bReserve1) = simpleSwap.getReserves();
    // console.log("aReserve1: ", aReserve1 / 10 ** tokenADecimals);
    // console.log("bReserve1: ", bReserve1 / 10 ** tokenADecimals);
    // console.log("amountOutB1: ", amountOut / 10 ** tokenADecimals);
    // console.log("balanceOfTakerB1: ", IERC20(tokenOut).balanceOf(taker) / 10 ** tokenADecimals);
    // console.log("balanceOfSimpleSwapA1: ", IERC20(tokenIn).balanceOf(address(simpleSwap)) / 10 ** tokenADecimals);
    // console.log("balanceOfSimpleSwapB1: ", IERC20(tokenOut).balanceOf(address(simpleSwap)) / 10 ** tokenBDecimals);
    // uint amountOut2M = bReserve1 - ((aReserve1 * bReserve1) / (aReserve1 + amountIn));
    // console.log("amountOutB2M: ", amountOut2M / 10 ** tokenADecimals);
    simpleSwap.swap(tokenIn, tokenOut, amountIn);
    // (aReserve, bReserve) = simpleSwap.getReserves();
    // console.log("aReserve2: ", aReserve / 10 ** tokenADecimals);
    // console.log("bReserve2: ", bReserve / 10 ** tokenADecimals);
    // uint amountOut2 = simpleSwap.swap(tokenIn, tokenOut, amountIn);
    // console.log("amountOutB2: ", amountOut2 / 10 ** tokenADecimals);
    // console.log("balanceOfSimpleSwapA2: ", IERC20(tokenIn).balanceOf(address(simpleSwap)) / 10 ** tokenADecimals);
    // console.log("balanceOfSimpleSwapB2: ", IERC20(tokenOut).balanceOf(address(simpleSwap)) / 10 ** tokenBDecimals);
    simpleSwap.swap(tokenIn, tokenOut, amountIn);
    simpleSwap.swap(tokenIn, tokenOut, amountIn);
    vm.stopPrank();
    uint256 reserveA;
    uint256 reserveB;
    (reserveA, reserveB) = simpleSwap.getReserves();
    // K 在 setUp() 賦值的
    assertGt(reserveA * reserveB, K);
  }
}
