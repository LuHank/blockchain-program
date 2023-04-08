pragma solidity ^0.4.25;
import "./zombiefactory.sol";

// 實作 cooldown timer - 避免整天都可以無限制餵食 kitties 且無限制繁殖
// 1. 餵食驅動殭屍冷卻
// 2. 殭屍不能再餵食 kitties 直到冷卻期間已過
// 定義一些輔助 function - 設定及檢查殭屍 readyTime
// passing struct as arguments: 傳遞 storage pointer 給 struct 當作 function ( private/internal ) 的參數。
//     function _doStuff(Zombie storage _zombie) internal {}
//     直接傳遞殭屍 reference 而不是傳僵屍 ID 並查找它。

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

  KittyInterface kittyContract;

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  // 驅動設定 readyTime
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  // 判斷最後餵食時間是否已經超過一天
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= now);
  }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}
