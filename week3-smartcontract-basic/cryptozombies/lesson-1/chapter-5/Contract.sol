pragma solidity ^0.4.25;

// struct 包含多種屬性。
// string: 用於任意長度的 UTF-8 ， 例如 string greeting = "Hello world!"

contract ZombieFactory {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

}
