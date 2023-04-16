pragma solidity ^0.4.25;
import "./zombiehelper.sol";

// 使用隨機數計算戰鬥結果
// - 選擇自己其中一隻殭屍以及對手
// - 如果你攻擊殭屍將有 70% 勝率，防禦殭屍將有 30% 勝率。
// - 所有殭屍(包含攻擊及防禦)根據戰鬥結果計算 winCount, lossCount 。
// - 如果攻擊的殭屍贏了，將可以升級並產生一個新的殭屍。
// - 如果攻擊殭屍輸了，只會增加 lossCount 。
// - 無論攻擊殭屍輸或贏，都會觸發 cooldown time 。

contract ZombieAttack is ZombieHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70; // 勝率

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }

  // 攻擊 function 帶入自己其中一隻殭屍以及對手殭屍
  function attack(uint _zombieId, uint _targetId) external {
  }
}
