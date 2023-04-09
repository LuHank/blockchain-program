pragma solidity ^0.4.25;

// 如何處理 variables
// state varibles: 永久儲存在 contract storage 。代表寫到區塊鏈就像寫入資料庫。

// uint data type: 無符號整數，必須為非負數。
// int data type: 有符號整數，可以為負數。
// uint = uint256 = 256-bit uint = 32 byte
// 還有其他類型如 uint8, uint16, uint32, uint64, etc... 但一般來說，除特定情況外，您只想簡單地使用 uint 。

contract ZombieFactory {

    uint dnaDigits = 16;

}