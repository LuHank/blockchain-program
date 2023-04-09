pragma solidity ^0.4.25;
import "./zombiefactory.sol";

// 實作利用 interface 與其他合約互動 - 宣告 interface 變數並指定 CryptoKitties 合約地址

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
  // 指向 CryptoKitties 合約
  // 可是要怎麼知道是指向 CryptoKitties 合約，萬一區塊鏈上有其他合約也開放 getKitty function ？ 
  // 因為有指定 CryptoKitties contract address.
  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  KittyInterface kittyContract = KittyInterface(ckAddress);

  function feedAndMultiply(uint _zombieId, uint _targetDna) public {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    _createZombie("NoName", newDna);
  }

}