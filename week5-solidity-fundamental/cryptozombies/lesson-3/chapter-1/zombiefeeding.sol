pragma solidity ^0.4.25;
import "./zombiefactory.sol";

// 呼叫外部合約方法且合約地址可改變
// 1. 宣告外部合約(contract NameInterface {})包含會用到的 function
// 2. 宣告合約變數
// 3. 可改變合約地址的 function (合約變數 = 外部合約(address))
// 4. 呼叫外部合約方法 (外部合約變數.function())

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

  // 合約不變性 - 不要 hard-coded CryptoKitties contract address ，避免 CryptoKitties contract 有 bug 或者合約被銷毀。
  // 造成我們的合約也要修改重新部署新的合約地址。(通知 users 使用新合約地址)
  // 合約有 bug 或者修改只能重新部署合約並使用新的合約地址。
  // 因此合理作法通常針對 external dependencies (外部依賴) 合約，建立一個 function 可以允許修改 DApp 重要部分，例如 external contract address 。
  // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  // KittyInterface kittyContract = KittyInterface(ckAddress);
  KittyInterface kittyContract;

  function setKittyContractAddress(address _address) external {
    kittyContract = KittyInterface(_address);
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
