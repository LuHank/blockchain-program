pragma solidity ^0.4.25;
import "./zombiefeeding.sol";

// 激勵僵屍升級 - function use aboveLevel modifier
// - 達到 level 2 ： 可以更改僵屍名稱。
// - 達到 level 20 ： 可以自己客製化僵屍 dna


contract ZombieHelper is ZombieFeeding {

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  // 達到 level 2 ： 可以更改僵屍名稱。
  // calldata 就像 memory ，只是只能用在 external function 。
  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]); // 需先驗證此僵屍的確是呼叫 function 的人所擁有
    zombies[_zombieId].name = _newName;
  }

  // 達到 level 20 ： 可以自己客製化僵屍 dna
  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]); // 需先驗證此僵屍的確是呼叫 function 的人所擁有
    zombies[_zombieId].dna = _newDna;
  }

}
