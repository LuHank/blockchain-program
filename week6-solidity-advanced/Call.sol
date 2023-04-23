// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

contract Call {
   
   function calls(address addr, uint256 s) public {
      /* 
      To Do: Call setA()
      (bool success, bytes memory data) = ...
      */
      (bool success, bytes memory data) = addr.staticcall(abi.encodeWithSignature("setA(uint256)", s));
      require(success, "staticall failed");
      /* 
      To Do: Call getA()
      (bool success, bytes memory data) = ...
      */
      uint256 a = abi.decode(data, (uint256));
      require(a == s, "decode failed");
   }
}

contract A {
   uint public a;
   function setA(uint256 _a) public {
      a = _a;
   }

   function getA() public view returns (uint256) {
      return a;
   }
}