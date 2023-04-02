// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 場景
// 1. 簽章 - 產生唯一 ID
// 2. 創建一個防止搶跑的合約 - commit reveal scheme
contract HashFunc {
    // keccak256 可以傳入任何型態的資料
    function hash(string memory text, uint num, address addr) external pure returns (bytes32) {
        // keccak256 input 必須為 bytes
        // 所以需把 raw data 編碼為 bytes - abi.encodePacked function or abi.encode function
        // keccak256 回傳 bytes32 = 64 碼 16 進位值 (會以 0x 開頭代表 16 進位)
        // 特性： input 微小修改， output 會很大改變。
        // 而且不可逆，所以很難找出 input 值。
        return keccak256(abi.encodePacked(text, num, addr));
    }

    // 場景：結果可能會 hash 碰撞 ( hash collision ) ： 不同 input 卻 hash 出相同 output 。 
    // 若傳入相鄰的 2 個 dynamic data types (例如 string ) 給 abi.encodePacked 就會有機會發生 hash collision 。
    // 碰撞參考以下的 collision function 。
    // abi.encode 與 abi.encodePacked 不同之處
    // abi.encodePacked 會把 input 資料壓縮， output 會比較小，且減少一些 abi.encode 的一些資訊。
    function encode(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encode(text0, text1);
    }
    function encodePacked(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encodePacked(text0, text1);
    }
    /* input "AAA", "BBB"
       abi.encode: 0x000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034242420000000000000000000000000000000000000000000000000000000000
       abi.encodePacked: 0x414141424242
         1. abi.encode 結果分成兩段且每一段前面多了右邊補足 192 碼 - 000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003
         2. abi.encode 最後會再多一段 58 碼 - 0000000000000000000000000000000000000000000000000000000000
         3. abi.encode 總共 386 碼
         但 abi.encodePacked 壓縮成只有 12 碼
    */
    
    // 例如 "AAAA","BBB" 與 "AAA","ABBB" 的 output 會一樣，造成 hash collision (hash 碰撞)。
    function collision(string memory text0, string memory text1) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text0, text1));
    }

    // 避免 hash collision 方法一：abi.encodePacked 改成 abi.encode 。
    function collisionSolution1(string memory text0, string memory text1) external pure returns (bytes32) {
        return keccak256(abi.encode(text0, text1));
    }

    // 避免 hash collision 方法一：abi.encodePacked 傳入參數將 2 個 dynamic data type ( string ) ， 插入一個 uint 。
    function collisionSolution2(string memory text0, uint x, string memory text1) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text0, text1));
    } 
}