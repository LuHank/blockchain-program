// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Delegatecall: 在合約內執行其他合約的程式碼。
/*
A: contract or EOA

regular call:
A calls B, send 100 wei
        B calls C, sends 50 wei
A ----> B ----> C
                msg.sender = B
                msg.value = 50
                execute code C's state variables
                use ETH in C

Delegatecall:
A calls B, send 100 wei
        B delegatecall C
A ----> B ----> C
                msg.sender = A
                msg.value = 100
                execute code B's state variables
                use ETH in B
*/

// 此合約的 state variables 宣告方式都務必要與 DelegateCall 合約相同，甚至順序都要相同，可能因為儲存到 slot 位置(storage layout)的關係。
// 例如在最前面加一個 state variables 就會得到奇怪的結果。
// 但若加在最後則不影響。
contract TestDelegateCall {
    // 如果加這行就會造成 DelegateCall contract 以下三個變數值會得到奇怪的值
    // address public owner;
    uint public num;
    address public sender;
    uint public value;
    // 若加在這裡則不影響
    address public owner;

    function setVars(uint _num) external payable {
        // num = _num;
        num = _num * 2;
        sender = msg.sender;
        value = msg.value;
    }
}

// 即使 DelegateCall 合約已部署不能修改邏輯，仍可以透過 TestDelegateCall 合約修改重新部署來修改 DelegateCall 合約的邏輯。
contract DelegateCall {
    uint public num;
    address public sender;
    uint public value;
    // _test 需傳入 TestDelegateCall contract address
    function setVars(address _test, uint _num) external payable {
        // delegatecall 兩種方式 - function signature or function selector
        // _test.delegatecall(
        //     abi.encodeWithSignature("setVars(uint256)", _num)
        // );
        // 可以不用寫 string
        // 好處是如果改了 function signature ，例如修改參數，則以下方法不用更動，但上一個方法則要更動。
        // contractAddress.delegatecall(abi.encodeWithSignature(”implementation contract’s function signature”), _num)
        // proxyContractAddress.delegatecall(abi.encodeWithSignature(implementationContractAddress.functionName.selector), _num)
        // proxyContractAddress.delegatecall(abi.encodeWithSignature(implementationContractInstance.functionName.selector), _num)
        (bool success, bytes memory data) = _test.delegatecall(
            abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num)
        );
        require(success, "delegatecall failed");
    }
}

// 執行結果
// 當執行 delegatecall 則 TestDelegateCall 的 state variables 不會改變，但 DelegateCall 的 state varaibles 會改變。
// DelegateCall 的 state variables 可以被修改，即使 DelegateCall 合約部署後不能修改合約內的 state variables 。
// 測試一： DelegateCall's setVars function 需傳入 TestDelegateCall contract address, 123
// 測試二： DelegateCall 已部署不能修改，但可以藉由 TestDelegateCall contract 重新部署去修改 DelegateCall 的 state variables 。
    // 修改 TestDelegateCall - num 的邏輯
    // 重新部署 TestDelegateCall 但 DelegateCall 使用舊的已部署合約
    // 重新測試一遍 DelegateCall' setVars function 並指定新的 TestDelegateCall contract address 可發現邏輯改變了