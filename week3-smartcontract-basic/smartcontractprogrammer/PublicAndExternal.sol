pragma solidity^0.4.12;

contract PublicAndExternal {
    // function test(uint[20] a) public pure returns (uint){
    //      return a[10]*2;
    // }

    function test2(uint[20] a) external pure returns (uint){
         return a[10]*2;
    }
}

// external function gas < public function gas, because public copied to memory, external read from calldata