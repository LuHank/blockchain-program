pragma solidity ^0.4.25;

/* 
  Function Modifiers
    - visibility modifiers - 控制何時何處可以呼叫 function
      - private: 合約內 function 可以呼叫
      - internal: 就像 private 但繼承的合約也可以呼叫
      - external: 只有合約外部才可以呼叫
      - public: 任何地方包含 internal, external
    - state modifiers - function 如何與區塊鏈互動
      - view: 只讀不會儲存或修改資料
      - pure: 完全不會存取/讀取區塊鏈資料
      如果從合約外部呼叫 view/pure，都不會花費任何 gas（但如果由另一個在內部 function 呼叫，它們確實會花費 gas）。
    - custom modifiers - 定義客製化邏輯來決定如何影響 function
      - onlyOwner
      - aboveLevel
    註：可以把所有 modifiers 放在一個 function: function test() external view onlyOwner anotherModifier {  ...  }
    - payable modifiers - function 可以接收 Ether
      - 因為錢 ( Ether ) 、 資料 ( transaction payload )、 合約程式碼全部都在 Ethereum ，所以可以在呼叫 function 同時付款給所屬合約。
      - 需要向合約支付一定的費用才能執行功能。
*/

// 使用者付錢 ( ETH ) 把殭屍升級，而錢會存在你擁有的合約裡。 - 遊戲賺錢方式

import "./zombiefeeding.sol";
contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether; // 升級費用

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee); // 先判斷是否有支付足夠升級費用
    zombies[_zombieId].level++; // 指定殭屍升級
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

/*
範例：
msg.value: 代表多少 Ether 將會傳給合約。
ether: Ethereum 內建單位。

contract OnlineStore {
  function buySomething() external payable {
    // Check to make sure 0.001 ether was sent to the function call:
    require(msg.value == 0.001 ether);
    // If so, some logic to transfer the digital item to the caller of the function:
    transferThing(msg.sender);
  }
}
*/

/*
DApp's JavaScript front-end cal the function from web3.js
// Assuming `OnlineStore` points to your contract on Ethereum:
OnlineStore.buySomething({from: web3.eth.defaultAccount, value: web3.utils.toWei(0.001)})

web3.utils.toWei(0.001): javascript function = 0.001 ether
可以想成 transaction 就像信封， function parameter 就像信的內容， value 就像你把錢放進信封裡。把信跟錢一起交給 recipient 。
*/