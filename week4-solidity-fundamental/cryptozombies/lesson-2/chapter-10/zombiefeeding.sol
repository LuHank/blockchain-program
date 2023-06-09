pragma solidity ^0.4.25;
import "./zombiefactory.sol";

// 餵食僵屍的食物 - CryptoKitties - 利用 interface 與其他合約互動。

// 殭屍吃甚麼？ CryptoKitties (需要呼叫 CryptoKitties 的 getKitty function) - 與其他合約互動，需要宣告一個 interface 。 
contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}
contract ZombieFeeding is ZombieFactory {

  function feedAndMultiply(uint _zombieId, uint _targetDna) public {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    _createZombie("NoName", newDna);
  }

}