pragma solidity ^0.4.25;
import "./zombiefeeding.sol";

// 重點：如何建立一個新的固定長度 array 並提供給 memory array 。
// Solidity 中成本較高的操作之一是宣告 storage ，尤其是寫入。 - declaring arrays in memory
// - 因為每次寫入或者改變資料都是永久被寫在區塊鏈上。
// - 全球數以千計的節點需要將資料存儲在它們節點的硬碟裡面。
// - 隨著區塊鏈的發展，這些數據量會隨著時間的推移而不斷增長。
// 為了降低成本，除非絕對必要，否則避免寫入資料到 storage 。
// 有時跟程式比較沒有效率的邏輯有關，有些人為了快速查找把 array 存入 state variable 而不想要每次呼叫 function 在記憶體就重建一次 array 。
// Solidity 跟其他語言不一樣的是
//     external view function 使用效率比較不好的迴圈是免費的，寧願不要使用 storage 搭配效率較好的程式邏輯。

// declaring arrays in memory 作法
//    在 function 內以及參數將 array 宣告為 memory ，表示不需要寫入任何資料到 storage 。

// 注意：array 宣告為 memory 必須使用固定長度。它們目前無法像使用 array.push() 的 storage array 那樣調整大小，儘管這可能會在 Solidity 的未來版本中改變。

contract ZombieHelper is ZombieFeeding {

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
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
    // 須注意使用 new 創建新的固定長度 array
    uint[] memory result = new uint[](ownerZombieCount[_owner]);

    return result;
  }

}
