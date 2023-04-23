// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract A {
   uint256 public a = 0;
   string public sA = "ABC";
   function setA(uint256 newA, string memory newString) external {
       a = newA;
       sA = newString;
   }
}


contract B {
   uint256 public amount;
   string public stringA;
   function callSetA(address a) external {
      bytes memory hash =
      abi.encodeWithSignature("setA(uint256,string)", 10, "EEE");
      (bool success, bytes memory data) = 
      a.delegatecall(hash);
   }
}

