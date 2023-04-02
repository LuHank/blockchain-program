// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract origin {
    address public tx_;
    address public msg_;
    A a;
    constructor(address addr) {
        a = A(addr);
    }
    function touch() public {
        tx_ = tx.origin;
        msg_ = msg.sender;
        a.touch_A();
    }

}

contract A {
    address public tx_;
    address public msg_;
    B b;
    constructor(address addr) {
        b = B(addr);
    }
    function touch_A() public {
        tx_ = tx.origin;
        msg_ = msg.sender;
        b.touch_B();
    }
}

contract B {
    address public tx_;
    address public msg_;
    C c;
    constructor(address addr) {
        c = C(addr);
    }
    function touch_B() public {
        tx_ = tx.origin;
        msg_ = msg.sender;
        c.touch_C();
    }
}

contract C {
    address public tx_;
    address public msg_;
    function touch_C() public {
        tx_ = tx.origin;
        msg_ = msg.sender;
    }
}