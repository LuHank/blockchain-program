// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { Arbitrage } from "../contracts/Arbitrage.sol";
import { FlashSwapSetUp } from "./helper/FlashSwapSetUp.sol";
import "forge-std/console.sol";

contract ArbitragePracticeTest is FlashSwapSetUp {
    Arbitrage public arbitrage;
    address maker = makeAddr("Maker");

    function setUp() public override {
        super.setUp();

        // mint 100 ETH, 10000 USDC to maker
        vm.deal(maker, 100 ether);
        usdc.mint(maker, 10_000 * 10 ** usdc.decimals());

        // maker provide liquidity to wethUsdcPool, wethUsdcSushiPool
        vm.startPrank(maker);
        // maker provide 50 ETH, 4000 USDC to wethUsdcPool
        usdc.approve(address(uniswapV2Router), 4_000 * 10 ** usdc.decimals());
        (uint amountA, uint amountB,uint liquidity) = uniswapV2Router.addLiquidityETH{ value: 50 ether }(
            address(usdc),
            4_000 * 10 ** usdc.decimals(),
            0,
            0,
            maker,
            block.timestamp
        );
        console.log("uniswap's amountA: ", amountA);
        console.log("uniswap's amountB: ", amountB);
        // 447213595498957 ，不是 2000000 開根號，因為有扣除 0.3% 手續費。
        console.log("uniswap's liquidity: ", liquidity);
        // maker provide 50 ETH, 6000 USDC to wethUsdcSushiPool
        usdc.approve(address(sushiSwapV2Router), 6_000 * 10 ** usdc.decimals());
        sushiSwapV2Router.addLiquidityETH{ value: 50 ether }(
            address(usdc),
            6_000 * 10 ** usdc.decimals(),
            0,
            0,
            maker,
            block.timestamp
        );
        vm.stopPrank();

        // deploy arbitrage contract
        arbitrage = new Arbitrage();
    }

    // Uni pool price is 1 ETH = 80 USDC (lower price pool)
    // Sushi pool price is 1 ETH = 120 USDC (higher price pool)
    // We can arbitrage between these two pools
    // Method 1 is
    //  - borrow WETH from lower price pool
    //  - swap WETH for USDC in higher price pool
    //  - repay USDC to lower pool
    // Method 2 is
    //  - borrow USDC from higher price pool
    //  - swap USDC for WETH in lower pool
    //  - repay WETH to higher pool
    // for testing convenient, we implement the method 1 here, and the exact WETH borrow amount is 5 WETH
    function test_arbitrage_with_flash_swap() public {
        console.log("weth: ", address(weth)); // 0x2e234DAe75C793f67A35089C9d99245E1C58470b
        console.log("usdc: ", address(usdc)); // 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
        console.log("arbitrage-weth: ", weth.balanceOf(address(arbitrage))); // 0

        uint256 borrowETH = 5 ether;

        // 測試驗證
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(usdc);
        // 錯誤方法，參考 Arbitrage.arbitrage();
        // uint256 repayAmountTest = uniswapV2Router.getAmountsOut(borrowETH, path)[1];
        // console.log("repayAmountTest: ", repayAmountTest); // 362644357

        // token0 is WETH, token1 is USDC
        arbitrage.arbitrage(address(wethUsdcPool), address(wethUsdcSushiPool), borrowETH);

        // we can earn 98.184746 with 5 ETH flash swap
        assertEq(usdc.balanceOf(address(arbitrage)), 98184746);
    }
}
