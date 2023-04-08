pragma solidity ^0.4.25;

// array: 想要收集一些東西。分為固定 fixed 以及動態 dynamic 。
// // Array with a fixed length of 2 elements:
// uint[2] fixedArray;
// // another fixed Array, can contain 5 strings:
// string[5] stringArray;
// // a dynamic Array - has no fixed size, can keep growing:
// uint[] dynamicArray;
// // an array of structs
// Person[] people; // dynamic Array, we can keep adding to it

// 因為 state variables 是永久除存在區塊鏈。所以建立一個 dynamic array of structs 是非常有用的，可以把它當成一個小型資料庫。

// variables 宣告為 public ， Solidity 會自動建立一個 getter function 。其他外部合約可以讀取但不能寫入。

contract ZombieFactory {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

}
