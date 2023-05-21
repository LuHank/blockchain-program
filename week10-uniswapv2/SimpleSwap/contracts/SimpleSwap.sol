// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract SimpleSwap is ISimpleSwap, ERC20 {
    using SafeMath for uint;

    uint256 private _reserveA;
    uint256 private _reserveB;
    address payable private _tokenA;
    address payable private _tokenB;

    event Mint(address indexed sender, uint amount0, uint amount1);

    constructor(address tokenA, address tokenB) ERC20("Simple Swap", "SIMS") {
        // 判斷是否為 contract 而非 EOA
        require(tokenA.code.length > 0, "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        require(tokenB.code.length > 0, "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        require(tokenA != tokenB, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        _tokenA = payable(tokenA);
        _tokenB = payable(tokenB);
    }

    // Implement core logic here 繼承時做 ISimpleSwap
    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        // test case 有固定的 amountIn => 參考 swapExactTokensForTokens
        require(tokenIn == _tokenA || tokenIn == _tokenB, "SimpleSwap: INVALID_TOKEN_IN");
        require(tokenOut == _tokenA || tokenOut == _tokenB, "SimpleSwap: INVALID_TOKEN_OUT");
        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        require(amountIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        (uint reserveA, uint reserveB) = getReserves();
        require(reserveA > 0 && reserveB > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY");
        // IERC20(tokenIn).transfer(address(this), amountIn);
        // 將 user 想要兌換的 tokenA 轉給 SimpleSwap contract
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        // uint k = reserveA * reserveB;
        // 假設原本是整除，那 -1 之後會讓它答案小 1，再 +1 後就變回原本的值
        // 假設原本不整除，那 -1 不會對值造成影響，再 +1 後就變回比原本大 1 的值
        // 後來的Ｋ值，要比原本的大一點
        amountOut = reserveB - ((reserveA * reserveB - 1) / ((reserveA + amountIn)) + 1);
        // amountOut = amountIn.mul(reserveB) / reserveA;
        require(amountOut > 0, "SimpleSwap: INSUFFICIENT_OUTPUT_AMOUNT");
        // Simple 不需要以下這行
        // require(amountOut > reserveB, "SimpleSwap: INSUFFICIENT_LIQUIDITY");
        // 將 tokenB 換給 user
        IERC20(tokenOut).transfer(msg.sender, amountOut);
        // 更新 reserve
        uint balanceIn = IERC20(tokenIn).balanceOf(address(this));
        uint balanceOut = IERC20(tokenOut).balanceOf(address(this));
        // Simple 不需要以下兩行
        // uint _amountIn = balanceIn > reserveA - amountOut ? balanceIn - (reserveB - amountOut) : 0;
        // require(_amountIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        _update(balanceIn, balanceOut);
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    } 

    /// @notice Update reserve
    /// @param balanceA The balance of contract's tokenA
    /// @param balanceB The balance of contract's tokenB
    function _update(uint balanceA, uint balanceB) private {
        _reserveA = balanceA;
        _reserveB = balanceB;
    }

    /// @notice Add liquidity to the pool
    /// @param amountAIn The amount of tokenA to add
    /// @param amountBIn The amount of tokenB to add
    /// @return amountA The actually amount of tokenA added
    /// @return amountB The actually amount of tokenB added
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(uint256 amountAIn, uint256 amountBIn)
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ) {
            (uint reserveA, uint reserveB) = getReserves();
            // 處理比例不同的問題
            uint actualAmountA;
            uint actualAmountB;
            if (reserveA == 0 && reserveB == 0) {
                (actualAmountA, actualAmountB) = (amountAIn, amountBIn);
            } else {
                uint amountBOptimal = quote(amountAIn, reserveA, reserveB);
                if (amountBOptimal <= amountBIn) {
                    (actualAmountA, actualAmountB) = (amountAIn, amountBOptimal);
                } else {
                    uint amountAOptimal = quote(amountBIn, reserveB, reserveA);
                    (actualAmountA, actualAmountB) = (amountAOptimal, amountBIn);
                }
            }
            // 將 token 轉給 SimpleSwap 當成 pool
            IERC20(_tokenA).transferFrom(msg.sender, address(this), actualAmountA);
            IERC20(_tokenB).transferFrom(msg.sender, address(this), actualAmountB);
            // 計算 liquidity
            uint balanceA = IERC20(_tokenA).balanceOf(address(this));
            uint balanceB = IERC20(_tokenB).balanceOf(address(this));
            uint _amountA = balanceA.sub(reserveA);
            uint _amountB = balanceB.sub(reserveB);
            uint _totalSupply = totalSupply();
            if (_totalSupply == 0) {
                liquidity = Math.sqrt(_amountA.mul(_amountB));
            } else {
                liquidity = Math.min(_amountA.mul(_totalSupply) / _reserveA, _amountB.mul(_totalSupply) / _reserveB);
            }
            require(liquidity > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
            // mint UNIF token 
            _mint(msg.sender, liquidity);
            // update reserve
            _update(balanceA, balanceB);
            emit Mint(msg.sender, _amountA, _amountB);
            emit AddLiquidity(msg.sender, _amountA, _amountB, liquidity);
            return (_amountA, _amountB, liquidity);
        }
    
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB) {
        // approve(address(this), liquidity);
        // transferFrom(msg.sender, address(this), liquidity);
        // 合約內 function 直接使用 transfer 就好，否則會有 approve 問題，因為呼叫者是 msg.sender 無法把 approve, transferFrom 放在一起。
        // Pair contract 也是用 transfer 處理
        // 將 liquidity 還給 SimpleSwap contract
        transfer(address(this), liquidity);

        // (uint reserveA, uint reserveB) = getReserves();
        address aToken = _tokenA;
        address bToken = _tokenB;
        uint balanceA = IERC20(aToken).balanceOf(address(this));
        uint balanceB = IERC20(bToken).balanceOf(address(this));
        liquidity = balanceOf(address(this));
        // 根據 liquidity 計算應該給 user 多少 token
        uint _totalSupply = totalSupply();
        amountA = liquidity.mul(balanceA) / _totalSupply;
        amountB = liquidity.mul(balanceB) / _totalSupply;
        require(amountA > 0 && amountB > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");
        // 把 user 歸還的 liquidity 燒毀
        _burn(address(this), liquidity);
        // transferFrom(address(this), msg.sender, amountA);
        // transferFrom(address(this), msg.sender, amountB);
        // 同上說明
        // 歸還 token 給 user
        IERC20(aToken).transfer(msg.sender, amountA);
        IERC20(bToken).transfer(msg.sender, amountB);

        balanceA = IERC20(aToken).balanceOf(address(this));
        balanceB = IERC20(bToken).balanceOf(address(this));
        // update reserve
        _update(balanceA, balanceB);
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() public view returns (uint256 reserveA, uint256 reserveB) {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    /// @notice Get the address of tokenA
    /// @return tokenA The address of tokenA
    function getTokenA() external view returns (address tokenA) {
        (address aToken, ) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        return aToken;
    }

    /// @notice Get the address of tokenB
    /// @return tokenB The address of tokenB
    function getTokenB() external view returns (address tokenB) {
        (, address bToken) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        return bToken;
    }
}
