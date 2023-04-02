// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
// require, revert, assert
// gas refund (send 1000 gas used 100 gas refund 900 gas), state updates are reverted
// custom error - save gas

// require: 驗證輸入以利存取控制
// revert: 效果與 require 相同，但如果需要巢狀 if statement, 則需要使用 revert 。
// assert: 用來檢查狀況，且結果應該都是 true ，如果是 false 代表 smart contract 有 bug (可能是無意間改變狀態)。
// custome error: 節省 gas 。因為越長的錯誤訊息會造成 require, revert 的 gas 越高。只能與 revert 搭配使用。
// 如果不符合條件與沒有控制 error ， gas 比較 ？

contract Errors {

    uint public count;
    function testNoError(uint _i) public {
        if (_i <= 10) {
            count += 1; // 1st - 43686, then - gas 26586 gas, pass 0 - 26574 gas
        } else {
            // Goerli 測試鏈場景：若 count > 1 則小狐狸會出現 We were not able to estimate gas. There might be an error in the contract and this transaction may fail.
            // 而且若硬要執行交易， gas fee 爆高。(1.07087677GoerliETH - 正常才 0.0.00149844GoerliETH)
            // require(count > 1, unicode"count 不可小於等於 1"); // noPass - 23700 gas, pass - 26695 gas
            count -= 1; // 如果 count <= 1 ，則不會執行此段程式碼。 // 若沒有上一行 require 控制，且當 count = 0 - 1 後，則交易會失敗且須支付 23676 gas 。
            // Goerli 測試鏈場景：若沒有上一行 require 控制，且當 count = 0 - 1 後，則小狐狸會出現 We were not able to estimate gas. There might be an error in the contract and this transaction may fail.
            // 而且若硬要執行交易， gas fee 爆高。(1.15621158GoerliETH - 正常才 0.0.00149844GoerliETH)
        }
    }

    function testRequire(uint _i) public pure {
        require(_i <= 10, "i > 10"); // pass 會繼續執行下一行 code， noPass 則會報錯 call to Errors.testRequire errored: Returned error: {"jsonrpc":"2.0","error":"execution reverted: i > 10","id":3411657391039778}
        // code
    }

    function testRevert(uint _i) public pure {
        if (_i > 10) {
            revert("i > 10"); // 同 testRequire
        }
        // if (i > 1) {
        //     // code
        //     if (_i > 2) {
        //         // more code
        //         if (i > 10) {
        //             revert("i > 10");
        //         }
        //     }
        // }
    }

    function testAssertCompare(uint _i) public pure {
        assert(_i <= 10); // pass 會繼續執行下一行 code， noPass 則會報錯 call to Errors.testAssertCompare errored: Returned error: {"jsonrpc":"2.0","error":"execution reverted","id":3411657391040432}
        // 不像 require, revert 可以傳 message 。
    }

    uint public num = 123;
    function testAssert() public view {
        assert(num == 123);
        // 當先呼叫 foo function ，就會造成 assert 的結果不會是 true 。
        // 會造成 gas refund, state varialbes updated will be undone.
    }

    function foo(uint _i) public {
        // accidentally update num
        num += 1;
        require(_i < 10); // pass - 26611 gas, noPass (交易 fail , 仍然要支付 gas, state variables undone) - 26611 gas
        // 當傳入 13 ，則 require 會 fail ，會消耗 gas 但會 gas refund 且 num += 1 會回復 ( undone ) 。
        // Injected Provider MetaMask：會報錯 Gas estimation errored with the following message (see below). The transaction execution will likely fail. Do you want to force sending?
    }

    // error MyError(address caller, uint i, string msg);
    error MyError(address caller, uint i);
    function testCustomError(uint _i) public {
        num += 1;
        if (_i > 10) {
            // 加上 message 後， gas 會比 require 便宜嗎？看起來沒有，除非不傳 message 。
            // revert MyError(msg.sender, _i, "very long error message error error error error"); // 26786 gas
            revert MyError(msg.sender, _i); // 26708 gas
        }
        // require(_i <= 10, "very long error message error error error error"); // 26748 gas (交易 fail , 仍然要支付 gas, state variables undone)
        // if (_i > 10) {
        //     revert( "very long error message error error error error"); // 26748 gas (交易 fail , 仍然要支付 gas, state variables undone)
        // }
    }
    // custom error 會顯示以下訊息
    // MyError
    // Parameters:
    // {
    //     "caller": {
    //     "value": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
    //     },
    //     "i": {
    //         "value": "11"
    //     }
    // }
}