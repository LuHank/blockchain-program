// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
calling parent functions
- direct
- super

   E
 /    \
F      G
 \     /
    H
*/

contract E {
    event Log(string message);

    function foo() public virtual {
        emit Log("E.foo");
    }

    function bar() public virtual {
        emit Log("E.bar");
    }
}

contract F is E {
    function foo() public virtual override {
        emit Log("F.foo");
        E.foo(); // direct way
    }

    function bar() public virtual override {
        emit Log("F.bar");
        super.bar(); // super way - parent is E
    }
}

contract G is E {
    function foo() public virtual override {
        emit Log("G.foo");
        E.foo(); // direct way
    }

    function bar() public virtual override {
        emit Log("G.bar");
        super.bar(); // super way - parent is E
    }
}

contract H is F, G {
    function foo() public virtual override (F, G) {
        emit Log("H.foo");
        F.foo(); // direct way
    }

    function bar() public virtual override (F, G) {
        emit Log("H.bar");
        super.bar(); // super way - 會呼叫所有 parent contract function: F, G, E
    }
}