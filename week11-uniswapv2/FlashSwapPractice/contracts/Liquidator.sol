// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Pair } from "v2-core/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Callee } from "v2-core/interfaces/IUniswapV2Callee.sol";
import { IUniswapV2Factory } from "v2-core/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Router01 } from "v2-periphery/interfaces/IUniswapV2Router01.sol";
import { IWETH } from "v2-periphery/interfaces/IWETH.sol";
import { IFakeLendingProtocol } from "./interfaces/IFakeLendingProtocol.sol";
import "forge-std/console.sol";

// This is liquidator contrac for testing,
// all you need to implement is flash swap from uniswap pool and call lending protocol liquidate function in uniswapV2Call
// lending protocol liquidate rule can be found in FakeLendingProtocol.sol
contract Liquidator is IUniswapV2Callee, Ownable {
    struct CallbackData {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
    }

    address internal immutable _FAKE_LENDING_PROTOCOL;
    address internal immutable _UNISWAP_ROUTER;
    address internal immutable _UNISWAP_FACTORY;
    address internal immutable _WETH9;
    uint256 internal constant _MINIMUM_PROFIT = 0.01 ether;

    constructor(address lendingProtocol, address uniswapRouter, address uniswapFactory) {
        _FAKE_LENDING_PROTOCOL = lendingProtocol;
        _UNISWAP_ROUTER = uniswapRouter;
        _UNISWAP_FACTORY = uniswapFactory;
        _WETH9 = IUniswapV2Router01(uniswapRouter).WETH();
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

    // 是給 FakeLendingProtocol 呼叫的？ => UniswapV2Pair.swap() 呼叫 (callback)
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        require(sender == address(this), "Sender must be this contract"); // 防止別人 call 只有自己 contract call 一種是直接 call 一種是透過 uniswap
        require(amount0 > 0 || amount1 > 0, "amount0 or amount1 must be greater than 0");

        // 4. decode callback data 身上已經有 80u
        CallbackData memory callback = abi.decode(data, (CallbackData));
        // 5. call liquidate 要清算別人，用 80u 清算比較便宜的 eth
        // address[] memory path = new address[](2);
        // path[0] = callback.tokenOut; // weth
        // path[1] = callback.tokenIn; // usdc
        // 因為想要在 FakeLendingProtocal 以 usdc 換 weth ，所以 amountIn 為 usdc 。(Liquidator approve FakeLendingPool)
        IERC20(callback.tokenIn).approve(_FAKE_LENDING_PROTOCOL, callback.amountIn);
        // 其他 DEX lending protocol - 使用 80usdc 換 weth
        IFakeLendingProtocol(_FAKE_LENDING_PROTOCOL).liquidatePosition(); // 換出 weth
        // 6. deposit ETH to WETH9, because we will get ETH from lending protocol
        IWETH(_WETH9).deposit{value: callback.amountOut}();
        // 7. repay WETH to uniswap pool => 從 data 來的 - repay
        require(IERC20(callback.tokenOut).transfer(msg.sender, callback.amountOut), "Repay failed");
        // 無法顯示，因為是使用 interface 呼叫合約。
        console.log("Liquidator.uniswapV2Call()'s msg.sender: ", msg.sender);
        // check profit
        // 收益要大於 0.01 ETH
        require(address(this).balance >= _MINIMUM_PROFIT, "Profit must be greater than 0.01 ether");
    }

    // we use single hop path for testing
    // 測項: path[0]=address(weth), path[1]=address(usdc), amountOut=80usdc
    function liquidate(address[] calldata path, uint256 amountOut) external {
        require(amountOut > 0, "AmountOut must be greater than 0");
        // 1. get uniswap pool address (把 path 打進去 getPair)
        address pool = IUniswapV2Factory(_UNISWAP_FACTORY).getPair(path[0], path[1]);
        // 2. calculate repay amount 
        // 資訊(data) 需要還多少錢 getAmountIn or getAmountOut 放入 data => 呼叫 swap ，還有 callback 需要知道的東西 (struct CallbackData)
        // CallbackData.field = ?
        // abi.encode
        // 要用多少 ETH 換出固定的 U
        // getAmountsIn 會 returns amounts array, 因為 amountsOut 在 UniswapV2Library.getAmountsIn() 是放在 amounts[1] ，所以 amounts[0] 是指 weth 。
        uint256 repayAmount = IUniswapV2Router01(_UNISWAP_ROUTER).getAmountsIn(amountOut, path)[0]; // 要借 80u 需要還多少 eth
        console.log("repayAmount: ", repayAmount); // 808878247646164300 = 0.808878247646164300 for 80 usdc 因為有扣除 feeOn
        // 3. flash swap from uniswap pool
        CallbackData memory callbackdata; // 對 CALLBACK 來說
        callbackdata.tokenIn = path[1]; // USDC
        callbackdata.tokenOut = path[0]; // WETH
        callbackdata.amountIn = amountOut; // 我要借多少錢 USDC
        callbackdata.amountOut =  repayAmount; // 我要還多少錢 WETH
        // token0 = WETH, token1 = USDC
        // 只跟他借 U, amountout0 = 0, amountout1 = 80u
        // uint amount0Out, => 0 代表沒有要借出 
        // uint amount1Out, => 有值代表要借出的錢 usdc
        // address to, => Liquidator from Pair for 80usdc
        // bytes calldata data => 要帶給 uniswapV2Call() 所需參數
        IUniswapV2Pair(pool).swap(0, amountOut, address(this), abi.encode(callbackdata)); // pool(weth,usdc)
        // 使用 new 部署合約，所以可以顯示。
        console.log("Liquidator.this: ", address(this));
        console.log("Liquidator's msg.sender: ", msg.sender);

    }

    receive() external payable {}
}
