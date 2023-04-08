pragma solidity ^0.4.25;
import "./zombiefeeding.sol";

// 其他額外的輔助方法或功能 - 達到某個等級可獲得特殊技能
// - 繼承 zombiefeeding contract
// - 利用 Function modifiers with arguments

contract ZombieHelper is ZombieFeeding {

  modifier aboveLevel(uint _level, uint _zombieId) {
    // 僵屍等級達到某個 level
    require(zombies[_zombieId].level >= _level);
    _;
  }

}
