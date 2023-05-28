// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Pair } from "v2-core/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Callee } from "v2-core/interfaces/IUniswapV2Callee.sol";
import "forge-std/console.sol";

// This is a pracitce contract for flash swap arbitrage
contract Arbitrage is IUniswapV2Callee, Ownable {
    // struct CallbackData {
    //     address borrowPool;
    //     address targetSwapPool;
    //     address borrowToken;
    //     address debtToken;
    //     uint256 borrowAmount;
    //     uint256 debtAmount;
    //     uint256 debtAmountOut;
    // }
    struct CallbackData {
        address wethUsdcSushiPool;
        address borrowToken;
        address debtToken;
        uint256 borrowAmount;
        uint256 debtAmount;
    }
    //
    // EXTERNAL NON-VIEW ONLY OWNER
    //

    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Withdraw failed");
    }

    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(msg.sender, amount), "Withdraw failed");
    }

    //
    // EXTERNAL NON-VIEW
    //

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        require(sender == address(this), "Sender must be this contract");
        require(amount0 > 0 || amount1 > 0, "amount0 or amount1 must be greater than 0");

        // 3. decode callback data
        CallbackData memory callbackdata = abi.decode(data, (CallbackData));

        // 驗證
        require(IERC20(callbackdata.borrowToken).balanceOf(address(this)) == 5000000000000000000, "borrow ETH failed");
        (uint256 reserveWeth, uint256 reserveUsdc,) = IUniswapV2Pair(callbackdata.wethUsdcSushiPool).getReserves();
        require(reserveWeth == 50000000000000000000, "Sushiswap's reserveWeth is wrong");
        require(reserveUsdc == 6000000000, "Sushiswap's reserveUsdc is wrong");

        // 4. swap WETH to USDC
        // swap 不須 approve
        // IERC20(callbackdata.borrowToken).approve(callbackdata.wethUsdcSushiPool, callbackdata.borrowAmount);
        // IUniswapRouter01().swapExactTokensForTokens(callbackdata.debtAmount, 0, , address(this), block.timestamp);
        // 445781790 debtAmount
        // 543966536 swapUSDCAmount
        // 98184746  expext profie 
        // 200000 / 45 = 444444444 至少需要
        // 兌換代幣需要使用到 -  - 因為要兌換 usdc ，其對於 pool 而言為 out ，所以使用 getAmountOut 。
        // amountIn = callbackdata.borrowAmount, reserveIn = reserveWeth, reserveOut = reserveUsdc
        // 根據 amountIn 數量的 reserveWeth，能夠得到多少數量的 reserveUsdc  (returns amountOut)。
        uint256 swapUSDCAmount = _getAmountOut(callbackdata.borrowAmount, reserveWeth, reserveUsdc); // 預估 5 weth 可在 Sushiswap 換到的 USDC
        require(swapUSDCAmount > callbackdata.debtAmount, "no profit");
        uint256 profit = swapUSDCAmount - callbackdata.debtAmount;
        require( profit == 98184746, "unexpect profit");
        // 須把 5 weth 轉給 Sushiswap ，才不會造成流動性不平衡(只得到 usdc 卻沒給 weth)。
        IERC20(callbackdata.borrowToken).transfer(callbackdata.wethUsdcSushiPool, callbackdata.borrowAmount);
        // IUniswapV2Pair(callbackdata.wethUsdcSushiPool).swap(0, callbackdata.debtAmount, address(this),""); // 不是強制換到 repayAmount 這樣是沒賺頭
        // *****注意*****: swap 參數 data 帶空白就可避免又 callback uniswapV2Call() ，可參考 UniswapV2Pair.swap()
        IUniswapV2Pair(callbackdata.wethUsdcSushiPool).swap(0, swapUSDCAmount, address(this),"");
        // 5. repay USDC to lower price pool
        require(IERC20(callbackdata.debtToken).transfer(msg.sender, callbackdata.debtAmount), "Repay Failed");
    }
    // Method 1 is
    //  - borrow WETH from lower price pool
    //  - swap WETH for USDC in higher price pool
    //  - repay USDC to lower pool
    // Method 2 is
    //  - borrow USDC from higher price pool
    //  - swap USDC for WETH in lower pool
    //  - repay WETH to higher pool
    // for testing convenient, we implement the method 1 here
    function arbitrage(address priceLowerPool, address priceHigherPool, uint256 borrowETH) external {
        // 1. finish callbackData
        require(borrowETH > 0, "borrowETH must be greater than zero");
        // 需要 pool 交易對的數量，才能計算(_getAmountIn)可兌換多少數量。
        (uint reserveIn, uint reserveOut,) = IUniswapV2Pair(priceLowerPool).getReserves();
        console.log("borrowETH: ", borrowETH); // 5000000000000000000
        console.log("reserveIn: ", reserveIn); // weth 50000000000000000000
        console.log("reserveOut: ", reserveOut); // usdc 4000000000
        
        // UniswapV2Pair 只有 mint, burn 才需考慮 fee ，也就是 addLiquidity, removeLiquidity 。
        // uint256 actulBorrowAmount = borrowETH + (borrowETH * 3 / 1000);
        // console.log("actulBorrowAmount: ", actulBorrowAmount);
        // uint256 repayAmount = _getAmountOut(borrowETH, reserveIn, reserveOut); // 362644357
        // uniswapV2Call() 還錢時會使用到 - 因為要借 weth ，其對 pool 而言為 in ，所以使用 getAmountIn 。
        // 針對 _getAmountIn 而言， reserveIn = usdc, reserveOut = weth，想借的幣才需要 fee 。
        // amountOut = borrowETH, reserveIn = reserveOut(usdc), reserveOut = reserveIn(weth)
        // 希望獲得一定數量(amountOut)的 reserveOut(weth) ，需要輸入多少數量(returns amountIn)的 reserveIn(usdc) 。
        uint256 repayAmount = _getAmountIn(borrowETH, reserveOut, reserveIn);  // 445781790

        CallbackData memory callbackdata;
        // 需要 Sushiswap 才能於 uniswapV2Call() 呼叫 swap()
        callbackdata.wethUsdcSushiPool = priceHigherPool;
        callbackdata.borrowToken = IUniswapV2Pair(priceLowerPool).token0(); // weth
        callbackdata.borrowAmount = borrowETH;
        callbackdata.debtToken = IUniswapV2Pair(priceLowerPool).token1(); // usdc
        callbackdata.debtAmount = repayAmount;
        console.log("borrowToken: ", callbackdata.borrowToken); // weth 0x2e234DAe75C793f67A35089C9d99245E1C58470b
        console.log("debtToken: ", callbackdata.debtToken); // usdc 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
        console.log("borrowAmount: ", callbackdata.borrowAmount); // 5000000000000000000
        console.log("debtAmount: ", callbackdata.debtAmount); // 362644357
        console.log("token0: ", IUniswapV2Pair(priceLowerPool).token0()); // token0 = weth 0x2e234DAe75C793f67A35089C9d99245E1C58470b
        console.log("token1: ", IUniswapV2Pair(priceLowerPool).token1()); // token1 = usdc 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
        console.log("token0: ", IUniswapV2Pair(priceHigherPool).token0()); // token0 = weth 0x2e234DAe75C793f67A35089C9d99245E1C58470b
        console.log("token1: ", IUniswapV2Pair(priceHigherPool).token1()); // token1 = usdc 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
        // 2. flash swap (borrow WETH from lower price pool)
        // IERC20(callbackdata.borrowToken).approve(priceLowerPool, borrowETH);
        IUniswapV2Pair(priceLowerPool).swap(borrowETH, 0, address(this), abi.encode(callbackdata));
        // Uncomment next line when you do the homework
        // IUniswapV2Pair(priceLowerPool).swap(borrowETH, 0, address(this), abi.encode(callbackData));
        // callbackdata 從低價 pool 借錢，然後去高價 pool 賣掉 並執行以上的 3, 4, 5 
        // callbackdata 自己做可以先忽略
    }

    //
    // INTERNAL PURE
    //

    // copy from UniswapV2Library
    function _getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = numerator / denominator + 1;
    }

    // copy from UniswapV2Library
    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
