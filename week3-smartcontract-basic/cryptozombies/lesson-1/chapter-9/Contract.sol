pragma solidity ^0.4.25;

// function 預設值為 public 。代表任何人或者合約都可以呼叫合約 function 並執行它。
// public function 並不總是需要得，因為會使您的合約容易受到攻擊。
// private function 只有合約內其他 function 可以呼叫此 function 。
// 慣例： private function 會以 _ 為命名。

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

}