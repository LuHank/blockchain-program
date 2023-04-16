// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// simple trick to save gas - load your state variables into memory
// - access to memory < access to storage 
//   就像後端或者 web 開發將資料存入資料庫比存在記憶體還慢

contract SaveGas {
    // uint public someStorageData;

    // function foo() public {
    //     // access storage
    //     someStorageData;

    //     // access to memory
    //     uint someMemoryData = 123;
    // }

    uint public n = 5;
    function noCache() external view returns (uint) {
        uint s = 0;
        // 重要的是 i < n 代表多次存取 storage data  (5 次)
        for (uint i = 0; i < n; i++) {
            s += 1; // 這裡不影響 gas
        }

        return s;
    }

    function Cache() external view returns (uint) {
        uint s = 0;
        // 只存取 storage data  - 1 次
        uint _n = n;
        
        // for loop 存取在記憶體的 state variable 而不是 storage
        for (uint i = 0; i < _n; i++) {
            s += 1; 
        }

        return s;
    }
}

// 部署與執行
// noCache() - execution cost = 3812 gas (Cost only applies when called by a contract)
// Cache() - execution cost = 3301 gas (Cost only applies when called by a contract)

/*
## no cache ##
n     |  gas
--------------
5     |  3812
10    |  5267
100   |  31457
1000  |  293357
## cache ##
n     |  gas
--------------
5     |  3301
10    |  4256
100   |  21446
1000  |  193346
*/