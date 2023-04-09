pragma solidity ^0.4.25;

// 讓 _generateRandomDna function 回傳半隨機 uint 
// 以太坊內置哈希函數 keccak256，它是 SHA3 的一個版本。哈希函數基本上將輸入映射為隨機的 64 位十六進制數 ( 256 bit )。
// 輸入的微小變化將導致哈希值發生較大變化。
// 目前拿來使用產生偽隨機數 ( pseudo-random ) 。
// keccak256() 傳入參數需為 bytes ，所以須先將資料打包成 bytes 。
// //6e91ec6b618bb462a4a6ee5aa2cb0e9cf30f7a052bb467b0ba58b8748c00d2e5
// keccak256(abi.encodePacked("aaaab"));
// //b1f078126895a1424524de5321b339ab00408010b7cf0e6ed451514981e58aa9
// keccak256(abi.encodePacked("aaaac"));

// 注意：區塊鏈中的安全隨機數生成是一個非常困難的問題。我們這裡的方法是不安全的，
// 但由於安全性不是我們的 Zombie DNA 的首要任務，因此對於我們的目的來說它已經足夠好了。

// typecasting 轉型
// uint8 a = 5;
// uint b = 6;
// // throws an error because a * b returns a uint, not uint8:
// uint8 c = a * b;
// // we have to typecast b as a uint8 to make it work:
// uint8 c = a * uint8(b);

contract ZombieFactory {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    function _createZombie(string _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        // 打包 _str 為 bytes 並 keccak256() hash 為 bytes32 然後轉型成 uint
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        // dna 只要 16 位長度
        return rand % dnaModulus;
    }

}