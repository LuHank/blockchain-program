// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { IUniswapV2Router01 } from "v2-periphery/interfaces/IUniswapV2Router01.sol";
import { IUniswapV2Factory } from "v2-core/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "v2-core/interfaces/IUniswapV2Pair.sol";
import { TestERC20 } from "../contracts/test/TestERC20.sol";
import "forge-std/console.sol";
import { Math } from "openzeppelin-contracts/contracts/utils/math/Math.sol";


contract UniswapV2PracticeTest is Test {
    IUniswapV2Router01 public constant UNISWAP_V2_ROUTER =
        IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public constant UNISWAP_V2_FACTORY =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address public constant WETH9 = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    TestERC20 public testUSDC;
    IUniswapV2Pair public WETHTestUSDCPair;
    address public taker = makeAddr("Taker");
    address public maker = makeAddr("Maker");

    function setUp() public {
        // fork block
        vm.createSelectFork("mainnet", 17254242);

        // deploy test USDC
        testUSDC = _create_erc20("Test USDC", "USDC", 6); // 建立 6 位小數點

        // mint 100 ETH, 10000 USDC to maker
        deal(maker, 100 ether);
        testUSDC.mint(maker, 10000 * 10 ** testUSDC.decimals());
        
        // mint 1 ETH to taker
        deal(taker, 100 ether);

        // create ETH/USDC pair
        WETHTestUSDCPair = IUniswapV2Pair(UNISWAP_V2_FACTORY.createPair(address(WETH9), address(testUSDC)));

        vm.label(address(UNISWAP_V2_ROUTER), "UNISWAP_V2_ROUTER");
        vm.label(address(UNISWAP_V2_FACTORY), "UNISWAP_V2_FACTORY");
        vm.label(address(WETH9), "WETH9");
        vm.label(address(testUSDC), "TestUSDC");
    }

    // # Practice 1: maker add liquidity (100 ETH, 10000 USDC)
    function test_maker_addLiquidityETH() public {
        // Implement here
        vm.startPrank(maker);
        // 增加流動性需先允許 UNISWAP_V2_ROUTER 可以 transfer 權限
        testUSDC.approve(address(UNISWAP_V2_ROUTER), 10000 * 10 ** testUSDC.decimals());
        // 增加流動性 WETH/testUSDC
        // address token, => address(testUSDC)
        // uint amountTokenDesired, => 10000 * 10 ** testUSDC.decimals()
        // uint amountTokenMin, => 0
        // uint amountETHMin, => 0
        // address to, => maker
        // uint deadline => block.timestamp * 20
        UNISWAP_V2_ROUTER.addLiquidityETH{value: 100 * 10 ** 18}(address(testUSDC), 10000 * 10 ** testUSDC.decimals(), 0, 0, maker, block.timestamp * 20);
        vm.stopPrank();
        // Checking
        // 檢查 reserve, reserve 儲存在 Factory contract
        IUniswapV2Pair wethUsdcPair = IUniswapV2Pair(UNISWAP_V2_FACTORY.getPair(address(WETH9), address(testUSDC)));
        (uint112 reserve0, uint112 reserve1, ) = wethUsdcPair.getReserves();
        assertEq(reserve0, 10000 * 10 ** testUSDC.decimals());
        assertEq(reserve1, 100 ether);
    }

    // # Practice 2: taker swap exact 100 ETH for testUSDC
    function test_taker_swapExactETHForTokens() public {
        vm.startPrank(maker);
        testUSDC.approve(address(UNISWAP_V2_ROUTER), 10000 * 10 ** testUSDC.decimals());
        UNISWAP_V2_ROUTER.addLiquidityETH{value: 100 * 10 ** 18}(address(testUSDC), 10000 * 10 ** testUSDC.decimals(), 0, 0, maker, block.timestamp * 20);
        // UNISWAP_V2_ROUTER.addLiquidityETH(address(testUSDC), 10000 * 10 ** testUSDC.decimals(), 0, 0, maker, block.timestamp * 200);
        vm.stopPrank();
        // Impelement here
        vm.startPrank(taker);
        address[] memory path = new address[](2);
        path[0] = address(WETH9);
        path[1] = address(testUSDC);
        // uint amountOutMin,  => 0
        // address[] calldata path, => path => (address(WETH9), address(testUSDC))
        // address to, => taker
        // uint deadline => block.timestamp
        UNISWAP_V2_ROUTER.swapExactETHForTokens{value: 100 * 10 ** 18}(0, path, taker, block.timestamp);
        vm.stopPrank();
        // Checking
        // # Disscussion 1: discuss why 4992488733 ?  
        // 0.997 = 100 - 0.003
        // (100 + 100*0.997) * (10000 - y) = 1000000
        // 有宣告 6 個 decimal
        // 可以用 getAmountIn() 得到 out 對應 swapExactETHForTokens()
        assertEq(testUSDC.balanceOf(taker), 4992488733);
        assertEq(taker.balance, 0);
    }

    // # Practice 3: taker swap exact 10000 USDC for ETH
    function test_taker_swapExactTokensForETH() public {
        // Impelement here
        vm.startPrank(maker);
        testUSDC.approve(address(UNISWAP_V2_ROUTER), 10000 * 10 ** testUSDC.decimals());
        UNISWAP_V2_ROUTER.addLiquidityETH{value: 100 * 10 ** 18}(address(testUSDC), 10000 * 10 ** testUSDC.decimals(), 0, 0, maker, block.timestamp * 20);
        vm.stopPrank();

        vm.startPrank(taker);
        testUSDC.mint(taker, 10000 * 10 ** testUSDC.decimals());
        testUSDC.approve(address(UNISWAP_V2_ROUTER), 10000 * 10 ** testUSDC.decimals());
        address[] memory path = new address[](2);
        path[0] = address(testUSDC);
        path[1] = address(WETH9);
        // uint amountIn, => 10000 * 10 ** testUSDC.decimals()
        // uint amountOutMin, => 3
        // address[] calldata path, => path => (address(testUSDC), address(WETH8))
        // address to, => taker
        // uint deadline => block.timestamp
        UNISWAP_V2_ROUTER.swapExactTokensForETH(10000 * 10 ** testUSDC.decimals(), 3, path, taker, block.timestamp);
        vm.stopPrank();
        // Checking
        // # Disscussion 2: original balance is 100 ether, so delta is 49924887330996494742, but why 49924887330996494742 ?
        assertEq(testUSDC.balanceOf(taker), 0);
        assertEq(taker.balance, 149924887330996494742);
    }

    // # Practice 4: maker remove all liquidity
    function test_taker_removeLiquidityETH() public {
        // Implement here
        IUniswapV2Pair wethUsdcPair = IUniswapV2Pair(UNISWAP_V2_FACTORY.getPair(address(WETH9), address(testUSDC)));
        vm.startPrank(maker);
        (uint112 reserveA, uint112 reserveB,) = wethUsdcPair.getReserves();
        console.log("reserveA: ", reserveA);
        console.log("reserveB: ", reserveB);
        console.log("WETH: ", TestERC20(WETH9).balanceOf(address(wethUsdcPair)));
        console.log("testUSDC: ", testUSDC.balanceOf(address(wethUsdcPair)));
        uint256 firstLiquidity;
        testUSDC.approve(address(UNISWAP_V2_ROUTER), 10000 * 10 ** testUSDC.decimals());
        (,,firstLiquidity) = UNISWAP_V2_ROUTER.addLiquidityETH{value: 100 * 10 ** 18}(address(testUSDC), 10000 * 10 ** testUSDC.decimals(), 0, 0, maker, block.timestamp * 20);
        console.log("reserveA: ", reserveA);
        console.log("reserveB: ", reserveB);
        console.log("WETH: ", TestERC20(WETH9).balanceOf(address(wethUsdcPair)));
        console.log("testUSDC: ", testUSDC.balanceOf(address(wethUsdcPair)));
        // MINIMUM_LIQUIDITY = 10 ** 3
        // 999999999999000 = Math.sqrt(TestERC20(WETH9).balanceOf(address(wethUsdcPair)).mul(testUSDC.balanceOf(address(wethUsdcPair)))).sub(MINIMUM_LIQUIDITY)
        // 100000000000000000000 * 10000000000 開根號 = 1000000000000000 - 1000 = 999999999999000
        // (uint112 oReserve0, uint112 oReserve1, ) = wethUsdcPair.getReserves();
        // console.log("oReserve0: ", oReserve0 / (10 ** testUSDC.decimals()));
        // console.log("oReserve1: ", oReserve1 / (10 ** 18));
        // uint oriLiquidity = Math.sqrt(oReserve0 * oReserve1);
        // 1000000000000
        // 100000000000000000000
        // uint testLiquidity = Math.sqrt(1 * 100000000);
        // uint liquidity = oriLiquidity - testLiquidity;
        
        console.log("firstLiquidity: ", firstLiquidity);
        wethUsdcPair.approve(address(UNISWAP_V2_ROUTER), firstLiquidity);
        // address token, => address(testUSDC)
        // uint liquidity, => 
        // uint amountTokenMin, => 0
        // uint amountETHMin, => 0
        // address to, => maker
        // uint deadline => block.timestamp
        UNISWAP_V2_ROUTER.removeLiquidityETH(address(testUSDC), firstLiquidity, 0, 0, maker, block.timestamp);
        console.log("WETH: ", TestERC20(WETH9).balanceOf(address(wethUsdcPair)));
        console.log("testUSDC: ", testUSDC.balanceOf(address(wethUsdcPair)));
        vm.stopPrank();
        // Checking
        // IUniswapV2Pair wethUsdcPair = IUniswapV2Pair(UNISWAP_V2_FACTORY.getPair(address(WETH9), address(testUSDC)));
        (uint112 reserve0, uint112 reserve1, ) = wethUsdcPair.getReserves();
        assertEq(reserve0, 1);
        assertEq(reserve1, 100000000);
    }

    function _create_erc20(string memory name, string memory symbol, uint8 decimals) internal returns (TestERC20) {
        TestERC20 testERC20 = new TestERC20(name, symbol, decimals);
        return testERC20;
    }
}
