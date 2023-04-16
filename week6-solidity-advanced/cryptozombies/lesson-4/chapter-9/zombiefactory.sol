pragma solidity ^0.4.25;
import "./ownable.sol";

// Zombie Leaderboard: 紀錄輸贏 - DApp 可以用以下方式記錄 (每種方式都有自己好處及取捨，取決於如何與資料互動)
// - mappings
// - leaderboard Struct
// - Zombie Struct => 目前先使用此方法，包含 winCount, lossCount

contract ZombieFactory is Ownable {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    struct Zombie {
      string name;
      uint dna;
      uint32 level;
      uint32 readyTime;
      // 選擇 uint16 的原因：
      // 因為包在 struct 所以盡可能將值設定小一點。
      // uint8 = 2^8 = 256 ，如果每天戰鬥可能不到一年就超過了。 uint16 = 2^16 = 65535 / 365 = 179 年才會超過。
      uint16 winCount;
      uint16 lossCount;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string _name, uint _dna) internal {
        // 生成殭屍就要把新增的變數初始化
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
