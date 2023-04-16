pragma solidity ^0.4.25;
import "./zombiehelper.sol";

// 如果殭屍輸了
// - 不會降級，只是增加 lossCount 。
// - 觸發 cooldown time: 隔一天才能再次進行攻擊。(不管輸贏都會觸發)

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
    if (rand <= attackVictoryProbability) {
      myZombie.winCount++;
      myZombie.level++;
      enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie"); // feedAndMultiply 已經有觸發 _triggerCooldown() 所以不用特別寫
    } else {
      // 輸的結果
      myZombie.lossCount++;
      enemyZombie.winCount++;
      _triggerCooldown(myZombie); // 殭屍一天只能攻擊一次。
    }
  }
}
