pragma solidity ^0.4.25;
import "./zombiefactory.sol";

// 了解如何更新 DApp 關鍵部分並保護合約不受使用者破壞。
// zombiefeeding contract 繼承 zombiefactory contract 繼承 ownable contract ，因此 zombiefeeding 可以使用 ownable contract 的 onlyOwner function modifier 。
// function modifier:
// 1. 使用關鍵字 modifier 取代 funtion 。
// 2. 不能像 function 可以直接被呼叫。
// 3. 可以在 function 定義的最後面加上 modifier name 來改變 function 行為。
// 特別注意：
// 給予 owner (合約擁有者) 針對合約具有特殊權限是常常需要的，但也有可能被惡意使用。例如 owner 可以增加一個後門 function ，允許自己把任何人的殭屍(甚至是代幣)轉移到自己身上。
// 因此重要的是「不是因為以太坊 DApp 就自動認定它是去中心化」，還需要仔細閱讀程式碼，確保合約不會被 owner 特殊控制。
// 所以作為開發人員，在保持對 DApp 的控制以修復潛在錯誤與，並且建一個 owner-less 平台以確保你的使用者信任有安全的保護他們的資料。


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

  // onlyOwner
  function setKittyContractAddress(address _address) external onlyOwner {
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
