pragma solidity ^0.4.25;

// 一個輔助 function 生成隨機 dna 數字。
// function return values and function modifiers
// return values: Solidity 宣告 return values 只需要 data type 不需要 data name 。 
// function modifiers:
// - view 針對區塊鏈資料只讀不寫
// - pure 無法訪問應用程序中的任何資料，只能回傳參數的運算。

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

    }

}