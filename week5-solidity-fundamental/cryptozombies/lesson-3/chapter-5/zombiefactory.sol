pragma solidity ^0.4.25;
import "./ownable.sol";

// 殭屍戰鬥系統 - level property 贏家可以
// 1. 提升 level
// 2. 獲得更多能力

// 攻擊/繁殖系統 - readyTime property 
// - 為了增加難度，設定冷卻時間，允許可再次攻擊或者繁殖的間隔時間。
// - 為了追蹤，使用 Solidity time units 。

// Solidity time units
// - now: 最新區塊的當前 unix timestamp (自 1970 年 1 月 1 日以來經過的秒數)
// - seconds
// - minutes = 60 seconds
// - hours = 3,600 seconds
// - days = 86,400 seconds
// - weeks = 604,800 seconds
// - years = 31,536,000 seconds

// 注意：傳統上，Unix 時間存儲在 32 位 ( 32-bit ) 數字中。這將導致“2038 年”問題，屆時 32 位 unix 時間戳將溢出並破壞許多遺留系統。
// 因此，如果我們希望我們的 DApp 從現在起繼續運行 20 年，我們可以使用 64 位 ( 64-bit ) 數字來代替。
// 但同時我們的使用者將不得不花費更多的 gas 來使用我們的 DApp。這是需要構思規劃的設計決策！


contract ZombieFactory is Ownable {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days; // 冷卻時間

    struct Zombie {
      string name;
      uint dna;
      uint32 level;
      uint32 readyTime;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string _name, uint _dna) internal {
        // level, readyTime
        // 因為 now 回傳的是 uint256 ，所以我們需要明確轉換為 uint32 。
        // now + cooldownTime => 會分別把 now, 1 days 轉換為秒數再相加。
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1;
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
