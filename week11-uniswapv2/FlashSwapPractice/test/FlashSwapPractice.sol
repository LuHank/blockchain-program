// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { FlashSwapSetUp } from "./helper/FlashSwapSetUp.sol";
import { FakeLendingProtocol } from "../contracts/FakeLendingProtocol.sol";
import { Liquidator } from "../contracts/Liquidator.sol";
import "forge-std/console.sol";


contract FlashSwapPracticeTest is FlashSwapSetUp {
    FakeLendingProtocol fakeLendingProtocol;
    Liquidator liquidator;

    address maker = makeAddr("Maker");

    function setUp() public override {
        super.setUp();

        // mint 100 ETH, 10000 USDC to maker
        vm.deal(maker, 100 ether);
        usdc.mint(maker, 10_000 * 10 ** usdc.decimals());

        // maker provide 100 ETH, 10000 USDC to wethUsdcPool
        vm.startPrank(maker);
        usdc.approve(address(uniswapV2Router), 10_000 * 10 ** usdc.decimals());
        uniswapV2Router.addLiquidityETH{ value: 100 ether }(
            address(usdc),
            10_000 * 10 ** usdc.decimals(),
            0,
            0,
            maker,
            block.timestamp
        );
        vm.stopPrank();

        // deploy fake lending protocol
        fakeLendingProtocol = new FakeLendingProtocol{ value: 1 ether }(address(usdc));

        // deploy liquidator
        liquidator = new Liquidator(address(fakeLendingProtocol), address(uniswapV2Router), address(uniswapV2Factory));
    }

    // 跟 Liquidator 借 usdc 然後跟 FakeSwapPractice 換 weth 最後拿 weth 還給 Liquidator
    // 只做到【借出 usdc 】？ => 不是， Liquidator.liquidate() 會呼叫 UniswapV2Pair.swap ，就會 callback Liquidator.uniswapV2Call()
    function test_flash_swap() public {
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(usdc);

        (uint reserve0, uint  reserve1,) = wethUsdcPool.getReserves();
        console.log("weth-reserve0: ", reserve0 / 10 ** 18);
        console.log("usdc-reserve1: ", reserve1 / 10 ** usdc.decimals());
        (uint reserve0Sushi, uint reserve1Sushi,) = wethUsdcSushiPool.getReserves();
        console.log("reserve0Sushi: ", reserve0Sushi / 10 ** 18);
        console.log("reserve1Sushi: ", reserve1Sushi / 10 ** usdc.decimals());
        console.log("msg.sender: ", msg.sender);
        console.log("this(FlashSwapPracticeTest): ", address(this));
        console.log("FakeLendingProtocol.usdc: ", usdc.balanceOf(address(fakeLendingProtocol)));
        // 借 80usdc 買 weth 去投資，然後還 weth
        // 因為 FakeLendingProtocol.swap() 規定要 80u 才能換 weth
        console.log("liquidator address: ", address(liquidator));
        liquidator.liquidate(path, 80 * 10 ** usdc.decimals());

        uint256 profit = address(liquidator).balance;
        assertEq(profit, 191121752353835700);
    }
}
