// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// regular: 若要呼叫 TestMultiDelegateCall's func1, func2 是分開呼叫的
// Multiple Delegatecall to batch function calls
// 可能會是危險的合約 參考以下 mint function

// 因為要保留 msg.sender 所以要改成使用 delegatecall
contract MultiDelegateCall {
    error DelegatecallFailed();
    // data 需傳入 deletegatecall contract (TestMultiDelegateCall) function selector
    function multiDelegateCall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);

        for (uint i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            results[i] = res;
        }
    }
}

// 為何要繼承 MultiDelegateCall ? => 可能是為了要簡化 demo
// 按照原來方式也可以 1. 移除繼承 2. multiDelegateCall 增加傳入 TestMultiDelegateCall contract address 3. MultiDelegateCall 增加 state varialbes of TestMultiDelegateCall
// Why use multi delegatecall ? Why not multi call?
// alice -> multi call --- function call ---> test (msg.sender = multi call contract)
// alice -> test contract --- delegatecall ---> test (msg.sender = alice)
contract TestMultiDelegateCall is MultiDelegateCall {
    event Log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint) {
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    // 可能會是危險的合約
    // 因為我只要傳 1 ether 但我呼叫 3 次 => 我的餘額就會變成 3 ether ，報酬率直接變成 3 倍。
    mapping(address => uint) public balanceOf;
    // WARNING: unsafe code when used in combination with multi-delegatecall
    // user can mint multiple times for the price of msg.value
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegateCall.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegateCall.func2.selector);
    }

    function getMintData() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegateCall.mint.selector);
    }

}

// 執行方式
// 部署: Helper contract, TestMultiDelegateCall contract
// 執行 Helper contract's getFunc1Data(輸入 1,2), getFunc2Data => 得到 function selector
// 執行 TestMultiDelegateCall's multiDelegateCall 輸入 ["0x3cb8008500000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002","0xb1ade4db"]
// 交易成功 查看 log => caller 的確是 EOA
// [
// 	{
// 		"from": "0xd9145CCE52D386f254917e481eB44e9943F39138",
// 		"topic": "0xfd33e90d0eac940755277aa91045b95664988beeeafc4ed7d1281a6d83afbc00",
// 		"event": "Log",
// 		"args": {
// 			"0": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"1": "func1",
// 			"2": "3",
// 			"caller": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"func": "func1",
// 			"i": "3"
// 		}
// 	},
// 	{
// 		"from": "0xd9145CCE52D386f254917e481eB44e9943F39138",
// 		"topic": "0xfd33e90d0eac940755277aa91045b95664988beeeafc4ed7d1281a6d83afbc00",
// 		"event": "Log",
// 		"args": {
// 			"0": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"1": "func2",
// 			"2": "2",
// 			"caller": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"func": "func2",
// 			"i": "2"
// 		}
// 	}
// ]

// 危險 mint 透過 multi-delegatecall 執行方式
// 部署: Helper contract, TestMultiDelegateCall contract
// 執行 Helper contract's getMintData => 得到 function selector
// 傳入 1 ether (msg.value = 1 ether) 執行 TestMultiDelegateCall's multiDelegateCall 輸入 ["0x1249c58b","0x1249c58b","0x1249c58b"]
// 查詢 TestMultiDelegateCall's balanceOf => 會得到 3 ether (3000000000000000000 wei)
// 合約只收到 1 ether 但使用者卻得到 3 ether 
