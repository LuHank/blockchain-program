// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ForAndWhileLoops {
    function loops() external pure {
        for (uint i = 0; i < 10; i++) {
            // code
            if (i == 3) {
                // 當 i 等於 3 時，會不執行 more code 然後繼續下一個 loop 。
                // skips current iteration
                continue; // skip one iteration of a loop - continue the next loop
            }
            // more code
            if (i == 5) {
                // 當 i 等於 5 時，就會跳出迴圈，不會執行到 9 。
                break;
            }
        }

        // while syntex
        // while (condition) {
        //     // code
        // }
        // while loop will run forever
        // while (true) {
        //     // code
        // }
        uint j = 0;
        while (j < 10) {
            j++;
        }
    }

    // 1 - n 加總
    // 但須注意 loop 越大， gas 愈高。
    function sum(uint _n) external pure returns (uint) {
        uint s;
        for (uint i = 1; i <= _n; i++) {
            s += i;
        }
        return s;
    }
}