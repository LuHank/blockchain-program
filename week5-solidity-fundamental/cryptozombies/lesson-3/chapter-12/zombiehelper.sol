pragma solidity ^0.4.25;
import "./zombiefeeding.sol";

// 使用迴圈建立 array 內容，而不是簡單偷懶將 array 儲存在 storage 造成需花費較多 gas 。

// 獲得使用者僵屍軍團場景簡單作法：
// - ZombieFactory contract 宣告 mapping 變數 owner 擁有多少僵屍
//   - mapping (address => uint[]) public ownerToZombies
//   - _createZombie function
//     ownerToZombies[owner].push(zombieId)
// - ZombieHelper contract 獲取使用者僵屍軍團
//   - function getZombiesByOwner(address _owner) external view returns (uint[] memory) { return ownerToZombies[_owner];}

// 此做法簡單但會有甚麼問題呢，之後會再增加 transfer function - 從某一 owner's zombie 移轉給另一個 owner
// transfer function:
// 1. new owner's ownerToZombies array 需加入此 zombie.
// 2. old owner's ownerToZombies array 需移除此 zombie.
// 3. old owner's array 需向前移一個索引以填補移除的位置.
// 4. array 長度減少 1 .
// step3 將會花費非常貴 gas ，因為位置移動我們必須對每一個 zombie 進行寫入 storage 動作，以維護 array order。
// 寫入 storage 是 Solidity 其中一種最貴的操作。因此才會造成每次 call transfer function 都需花費昂貴 gas 。
// 而且最糟的是每次呼叫都花費不同數量的 gas ，取決於 owner 有多少 zombie 且移轉的 zombie 位於哪一個位置 (index) 。
// 注意：當然，我們可以只移動 array 的最後一個殭屍來填充缺失的 slot，並將 array length 減一。但是每次我們進行交易時，我們都會改變殭屍軍隊的順序。

// external view function 不會消耗 gas 。  
//     getZombiesByOwner functoin 使用 for 環圈 iterate 整個殭屍 array 並構建屬於該特定所有者的殭屍 array 。
//     transfer function 會更便宜，因為我們不需要重新排序存儲中的任何數組，雖然有點違反直覺，但這種方法整體上更便宜。


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

  // iterate (遍歷) 所有 zombies，比較僵屍對應的 owner 是否匹配，如果是就加入 result array 。
  // 同樣獲取使用者僵屍軍團，但比上面方法便宜，因為不會使用到 mapping storage 及寫入 mapping storage 。
  function getZombiesByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]); // 存放殭屍 ID
    uint counter = 0; // 存放擁有殭屍的索引
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}
