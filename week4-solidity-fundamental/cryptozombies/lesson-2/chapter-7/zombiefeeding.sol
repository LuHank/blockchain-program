pragma solidity ^0.4.25;
import "./zombiefactory.sol";

// feedAndMultiply - 賦予殭屍餵食及繁殖能力
// 補充： 
// 1. function 內操作 struct, arry 才需要標示清楚 data location (storage, memory, calldata)
// 2. 其他狀況不需特別標示，例如 宣告變數 在 function 外面其預設就會是 storage ，宣告變數在 functions 內部其預設就會是 memory 。 

contract ZombieFeeding is ZombieFactory {
  // give our zombies the ability to feed and multiply!
  function feedAndMultiply(uint _zombieId, uint _targetDna) public {
    require(msg.sender == zombieToOwner[_zombieId]); // 只有我自己可以餵食自己的殭屍
    Zombie storage myZombie = zombies[_zombieId]; // 獲得僵屍的 DNA
  }

}

// Most of the time you don't need to use these keywords because Solidity handles them by default. 
// State variables (variables declared outside of functions) are by default storage and written permanently to the blockchain, 
// while variables declared inside functions are memory and will disappear when the function call ends.

// However, there are times when you do need to use these keywords, 
// namely when dealing with structs and arrays within functions:
// contract SandwichFactory {
//   struct Sandwich {
//     string name;
//     string status;
//   }

//   Sandwich[] sandwiches;

//   function eatSandwich(uint _index) public {
//     // Sandwich mySandwich = sandwiches[_index];

//     // ^ Seems pretty straightforward, but solidity will give you a warning
//     // telling you that you should explicitly declare `storage` or `memory` here.

//     // So instead, you should declare with the `storage` keyword, like:
//     Sandwich storage mySandwich = sandwiches[_index];
//     // ...in which case `mySandwich` is a pointer to `sandwiches[_index]`
//     // in storage, and...
//     mySandwich.status = "Eaten!";
//     // ...this will permanently change `sandwiches[_index]` on the blockchain.

//     // If you just want a copy, you can use `memory`:
//     Sandwich memory anotherSandwich = sandwiches[_index + 1];
//     // ...in which case `anotherSandwich` will simply be a copy of the
//     // data in memory, and...
//     anotherSandwich.status = "Eaten!";
//     // ...will just modify the temporary variable and have no effect
//     // on `sandwiches[_index + 1]`. But you can do this:
//     sandwiches[_index + 1] = anotherSandwich;
//     // ...if you want to copy the changes back into blockchain storage.
//   }
// }