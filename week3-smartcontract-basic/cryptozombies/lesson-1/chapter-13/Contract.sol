pragma solidity ^0.4.25;

// event: 合約將區塊鏈上發生的事情傳達給前端程式的一種方式，讓前端程式可以「監聽」某些 event 並在它們發生時採取行動。

// 合約 event 宣告及觸發
// // declare the event
// event IntegersAdded(uint x, uint y, uint result);

// function add(uint _x, uint _y) public returns (uint) {
//   uint result = _x + _y;
//   // fire an event to let the app know the function was called:
//   emit IntegersAdded(_x, _y, result);
//   return result;
// }
// 前端程式監聽 event 並採取行動
// YourContract.IntegersAdded(function(error, result) {
//   // do something with result
// })

contract ZombieFactory {
    // 宣告 event
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    function _createZombie(string _name, uint _dna) private {
        // event 需要 id ，因此將建立殭屍的 index 存入 id ，因為 index 是從 0 開始，所以需要扣除 1 。
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        // 觸發 event
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}