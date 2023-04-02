pragma solidity ^0.4.25;
import "./zombiefactory.sol";
contract ZombieFeeding is ZombieFactory {

  function feedAndMultiply(uint _zombieId, uint _targetDna) public {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    // 生成新 DNA 的殭屍，透過殭屍 DNA 以及 餵食的 DNA
    _targetDna = _targetDna % dnaModulus; // 確保餵食的 DNA 只有 16 digits
    uint newDna = (myZombie.dna + _targetDna) / 2; // 生成新的 DNA
    _createZombie("NoName", newDna); // 利用新的 DNA 創建新的殭屍
  }

}