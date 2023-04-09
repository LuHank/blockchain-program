pragma solidity ^0.4.25;

// createRamdomZombie public function - 限制一個帳號只能生成一隻殭屍
// 補充： Solidity 無法比較原生字串，須把兩個字串經過 keecak256 hash 後比較。 (參考最後的說明)

contract ZombieFactory {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string _name, uint _dna) private {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        // 如果使用者可以無限制生成殭屍就失去樂趣，所以需要限制每一個帳號只能生成一隻殭屍。
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}

// Solidity 無法比較原生字串，須把兩個字串經過 keecak256 hash 後比較。
// function sayHiToVitalik(string memory _name) public returns (string memory) {
//   // Compares if _name equals "Vitalik". Throws an error and exits if not true.
//   // (Side note: Solidity doesn't have native string comparison, so we
//   // compare their keccak256 hashes to see if the strings are equal)
//   require(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("Vitalik")));
//   // If it's true, proceed with the function:
//   return "Hi!";
// }