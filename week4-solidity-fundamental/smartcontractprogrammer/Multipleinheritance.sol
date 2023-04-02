// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Order of inheritance - most base-like to devirved
// X is baseline contract
// Y is more base-like than Z

/*
   X
 / |
Y  |
 \ |
   Z

// order of most base like to derived
// X, Y, Z

  X
 / \
Y   A
|   |
|   B
 \  /
  Z
X, , Y, A, B, Z
*/

contract X {
    // virtual: 可以被繼承且被子合約客製化的 function
    function foo() public pure virtual returns (string memory) {
        return "X";
    }

    function bar() public pure virtual returns (string memory) {
        return "X";
    }

    // 就算子合約沒有客製化此 function，還是會有此 function 。
    function x() public pure returns (string memory) {
        return "X";
    }
}

contract Y is X {
    // virtual: 可以被繼承且被子合約客製化的 function
    function foo() public pure virtual override returns (string memory) {
        return "Y";
    }

    function bar() public pure virtual override returns (string memory) {
        return "Y";
    }

    // 就算子合約沒有客製化此 function，還是會有此 function 。
    function y() public pure returns (string memory) {
        return "Y";
    }
}

contract Z is X, Y {
// contract Z is Y, X { // 繼承順序不對就無法編譯
    // override 的順序就沒差了
    function foo() public pure override (X, Y) returns (string memory) {
        return "Z";
    }

    function bar() public pure override (Y, X) returns (string memory) {
        return "Z";
    }
}