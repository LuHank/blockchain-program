// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// low-level function call - 呼叫另一個合約 function


contract TestCall {
    string public message;
    uint public x;

    event Log(string message);

    // 如果呼叫不存的 function ，fallback function 就會被執行。
    fallback() external payable {
        emit Log("fallback was called");
    }

    function foo(string memory _message, uint _x) external payable returns (bool, uint) {
        message = _message;
        x = _x;
        return (true, 999);
    }
}

contract Call {
    bytes public data;
    function callFoo(address _test) external payable {
        // 注意：需要支付 111 wei 才能呼叫成功，否則交易會失敗。
        // 5000 gas 會失敗因為不足以支付 foo function 內修改 state variable 的費用。
        // 移除此限制就會成功了
        (bool success, bytes memory _data) = _test.call{value: 111, gas: 5000}(abi.encodeWithSignature(
            "foo(string,uint256)", "call foo", 123
            ));
        require(success, "call failed");
        data = _data;
    }

    function callDoesNotExist(address _test) external {
        // 留空忽略第二個 response 參數
        // 如果把被呼叫的合約的 fallback function 移除就會造成交易失敗
        (bool success, ) = _test.call(abi.encodeWithSignature("doesNotExist()"));
        require(success, "callDoesNotExist failed");
    }
}