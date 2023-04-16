pragma solidity ^0.4.25;
import "./zombiehelper.sol";
contract ZombieAttack is ZombieHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }

  // 檢查殭屍擁有者是否為 msg.sender
  function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId) {
    // 宣告自己選擇的殭屍以及對手殭屍
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100); // 傳入 100 係數並回傳隨機數
  }
}
