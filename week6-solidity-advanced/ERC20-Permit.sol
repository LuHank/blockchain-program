// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 參考： https://youtu.be/lFKcga4Y6Ys
// 簽署一個訊息，允許其他人可以代表你來花費你的 ERC20 token 。
// 並讓 contract 知道你批准 spender 花費你多少 value 的 ERC20 token 。
// 1. sign a messag
// 2. send the message by relayer
// 3. contract understand you want to give allowance to spender 。

// ERC2612 已經是 Final 階段。
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Permit.sol

// 使用 eip712 signature 讓 contract 知道使用者想要允許特定的 spender 可以花費他的 ERC20 token
// - permit function: 只要有 v, r, s ( signature 解析出來的) 的任何人都可以呼叫    
// - 如果驗證簽名是合法的，就可以呼叫 approval 允許特定的 spender 可以花費他的 ERC20 token
// - nonces function: 防止重放攻擊
// - DOMAIN_SEPERATOR function: 在 eip712 建立的 domain

// 使用 OpenZeppelin - Contract Wizard -> ERC20 並點選 Permit -> 使用 Solidity 開啟
import "./ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {}
    function mint(address to, uint256 value) external {
        _mint(to, value);
    }
}

// 執行步驟
// 1. mint 100000 token 給自己
// 2. 