pragma solidity ^0.4.25;

// 建立一個新的 struct 並加入到一個 struct array

// struct Person {
//   uint age;
//   string name;
// }

// Person[] public people;

// // create a New Person:
// Person satoshi = Person(172, "Satoshi");
// // Add that person to the Array:
// people.push(satoshi);

// 簡單化： people.push(Person(16, "Vitalik"));

// array.push() 會從最後按照順序加入。

contract ZombieFactory {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    function createZombie (string _name, uint _dna) {
        zombies.push(Zombie(_name, _dna));
    }

}