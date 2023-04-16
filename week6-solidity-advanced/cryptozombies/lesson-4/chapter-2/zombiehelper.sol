pragma solidity ^0.4.25;
import "./zombiefeeding.sol";

// withdraw the ether from the contract
/*
你可以擁有像這樣不受任何人控制的去中心化市場：
transfer 可以轉錢給任何地址，
- 例如如果有人多付錢，就可以利用 transfer 轉回給他。
  uint itemFee = 0.001 ether;
  msg.sender.transfer(msg.value - itemFee);
- 買方付錢給賣方
  先把賣方 address 存在 storage 然後把買方錢付給賣方
  seller.transfer(msg.value)
*/

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    // owner() from Ownable contract
    // address 需宣告為 payable 才能收錢，也就是不能 transfer 給單純的 address 。
    // address 從 uint160 轉型為 address payable ，就可以使用 transfer 轉錢給它。
    address payable _owner = address(uint160(owner())); // 必須指定明確 uint160 data type
    _owner.transfer(address(this).balance); // address(this).balance 代表合約總餘額
  }

  // 有可能物價上漲 ( ETH 漲了 10 倍 ) ，這樣會造成遊戲升級費用太貴，因此要有一個功能可以修改升級費用。
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level++;
  }

  function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}
