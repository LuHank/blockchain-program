pragma solidity ^0.4.25;
import "./zombiehelper.sol";

// 好遊戲都會有某種程度的隨機性
// Solidity 無法安全做到隨機性
// 注意：不可拿相同 inputs 產生隨機數


contract ZombieAttack is ZombieHelper {
  uint randNonce = 0;

  // modulus 係數
  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    // 將訊息轉成 bytes -> 傳入 keccak256 編碼成 hash -> 產生 bytes32 然後轉成 uint -> 取兩位數
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }
}

/*
以下方法容易受到不誠實節點的攻擊
  因為假設一個拋硬幣遊戲套用以下隨機數 (random >= 50 is heads 正面, random < 50 is tails 反面) ，正面贏錢反面輸錢。
  不誠實節點可以拋到贏錢才把交易加到我要打包的下一個區塊。所以區塊鏈上所有資料讓所有人都可以看到是有難度的。
  當然所有節點都在競爭打包區塊，所以不誠實節點可以利用此點賺錢的機率非常低因為需要花費更多資源，除非賭注非常大例如一億，那就值得冒險攻擊了。
  那要如何產生隨機數才安全？
    參考： https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract
    - 使用 Oracle 從 Ethereum 外部存取隨機數 function 。
    - 不要使用 blockhash, timestamp, or other miner-defined value ，因為礦工都可以預測。
    - 即使使用者預先提交一個數字，但仍可以決定是否要顯示。
    - 彩票關票前，都不可以產生數字，因為合約上任何狀態都看的到，即使是 private 。
    - 任何號碼在產生及使用之間，都有可能在區塊產出前就被知道了。因為 EVM 不會超越實體主機效能。

// Generate a random number between 1 and 100:
uint randNonce = 0;
uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;
randNonce++;
uint random2 = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;
*/