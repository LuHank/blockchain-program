pragma solidity ^0.4.25;
import "./zombiehelper.sol";

// 以 randMod() 決定輸贏(基準為 attackVictoryProbability )並更新 winCount, lossCount

contract ZombieAttack is ZombieHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }

  function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    // 以 attackVictoryProbability 為基準，因為是 70% 勝率，所以小於等於 70 就是贏。
    if (rand <= attackVictoryProbability) {
      // 自己的殭屍進行攻擊贏了： 
      // - winCount 增加, level 晉級, 對手殭屍 lossCount 增加。
      // - 而且可以產生一支新的殭屍(帶入自己殭屍 ID, 對手殭屍 DNA, 物種取名為 zombie )
      myZombie.winCount++;
      myZombie.level++;
      enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    }
  }
}
