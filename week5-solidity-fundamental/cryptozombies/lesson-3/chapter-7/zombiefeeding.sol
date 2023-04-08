pragma solidity ^0.4.25;
import "./zombiefactory.sol";

// 修改 feedAndMultiply function 可以考慮到 cooldown timer
//     一個重要的安全實踐是檢查所有 pubblic/external function，並嘗試考慮用戶可能濫用它們的方式。(除非有 onlyOwner modifier )
//     feedAndMultiply function 為 public ，這造成使用者可以傳入他們想要的 dna, species 而不照我們的規則走。
//     更深入調查，其實此 function 只有被 feedOnKitty() 呼叫，所以可以設定為 internal 以防止漏洞。

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

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= now);
  }

  // public -> internal: 防止安全漏洞 (因為我們不想要讓使用者傳入任何自己想要的 dna )
  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    // 限制冷卻時間已過才可以餵食
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    // 餵食完成須設定冷卻時間
    _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}
