pragma solidity ^0.4.25;

// 隨機殭屍生成器
// 使用 public function 將所有組合起來。
// 利用殭屍名字及殭屍隨機 dna 生成殭屍。

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
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        // 利用殭屍名字隨機生成 dna
        uint randDna = _generateRandomDna(_name);
        // 傳入殭屍名字及其 dna 並建立此殭屍
        _createZombie(_name, randDna);
    }

}