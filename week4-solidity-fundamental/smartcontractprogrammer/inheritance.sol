// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract A {
    // virtual: 可以被繼承且被子合約客製化的 function
    function foo() public pure virtual returns (string memory) {
        return "A";
    }

    function bar() public pure virtual returns (string memory) {
        return "A";
    }

    // 就算子合約沒有客製化此 function，還是會有此 function 。
    function baz() public pure returns (string memory) {
        return "A";
    }
}

// B 繼承 A 並且客製化一些 function
// 一種方式是複製 A 的 function 程式碼，但會造成重複。
contract B is A {
    // override: 客製化父合約 function
    // virtual: 可以被繼承且被子合約客製化的 function
    function foo() public pure virtual override returns (string memory) {
        return "B";
    }

    function bar() public pure override returns (string memory) {
        return "B";
    }
}

contract C is B {
    function foo() public pure override returns (string memory) {
        return "C";
    }
}