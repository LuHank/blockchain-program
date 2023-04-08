pragma solidity ^0.4.25;
import "./zombiefeeding.sol";

// DApp 需要一個方法查看使用者整個僵屍軍團 - 如果需要個人資料頁面顯示則需要使用 web3.js 來呼叫此 function 
// 因為只讀取區塊鏈資料所以 function 宣告為 view 以優化 gas - 不用花費 gas 。(預設值為空白代表讀寫資料到區塊鏈， gas 會比較貴 。)
// view 為何不用花費 gas ，因為只讀取區塊鏈資料並未改變區塊鏈資料。
//     告訴 web3.js 它只需要查詢你的本地以太坊節點來執行該函數，它實際上不需要在區塊鏈上創建交易（這需要在每個節點上運行，並且會消耗 gas）。
// 注意： function external view 必須是外部呼叫此 view function 才是免費， 若是同一合約其他非 view function 呼叫此 view function ，仍然需要 gas 因為其他 function 會創建交易，並在每個節點執行 function 驗證。

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

  // function 宣告為 external view 則使用 web3.js 呼叫此 function 是不用花費 gas 。
  function getZombiesByOwner(address _owner) external view returns(uint[]) {

  }

}
