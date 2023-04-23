// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract C {
    // NOTE: storage layout must be the same as contract A
    uint public numCall;
    address public senderCall;
    uint public valueCall;
    uint public numDelegatecall;
    address public senderDelegatecall;
    uint public valueDelegatecall;

    function setVarsCall(uint _num) public payable {
        numCall = _num;
        senderCall = msg.sender;
        valueCall = msg.value;
    }

    function setVarsDelegatecall(uint _num) public payable {
        numDelegatecall = _num;
        senderDelegatecall = msg.sender;
        valueDelegatecall = msg.value;
    }
}

// NOTE: Deploy this contract first
contract B {
    // NOTE: storage layout must be the same as contract A
    uint public numCall;
    address public senderCall;
    uint public valueCall;
    uint public numDelegatecall;
    address public senderDelegatecall;
    uint public valueDelegatecall;

    function setVarsCall(uint _num) public payable {
        numCall = _num;
        senderCall = msg.sender;
        valueCall = msg.value;
        
    }

    function setVarsDelegatecall(uint _num) public payable {
        numDelegatecall = _num;
        senderDelegatecall = msg.sender;
        valueDelegatecall = msg.value;
    }

    function setVarsWithDelegatecall(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVarsDelegatecall(uint256)", _num)
        );
    }

    function setVarsWithCall(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.call{value: msg.value}(
            abi.encodeWithSignature("setVarsCall(uint256)", _num)
        );
    }
}

contract A {
    uint public num;
    address public sender;
    uint public value;

    function setVarsWithDelegatecall(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVarsDelegatecall(uint256)", _num)
        );
    }

    function setVarsWithCall(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.call{value: msg.value}(
            abi.encodeWithSignature("setVarsCall(uint256)", _num)
        );
    }
}
