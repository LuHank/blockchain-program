pragma solidity ^0.4.25;

// 資安漏洞： setKittyContractAddress is external 且沒有限制權限，造成任何人都可以更改合約，破解你的 DApp 。
// 一般實務做法：建立一個 Ownable contract ，提供人員特殊權限。
// Ownable contract: 只有合約擁有者有特別權限。
// taken from the OpenZeppelin Solidity library. 
// OpenZepplin 是一個提供安全的 library ，經過社區審查，可使用在自己的 DApp 。
// onlyOwner 是一般常見的需求，大部分 Solidity DApp 開發者都會在第一個合約複製貼上 Ownable contract 。
// Ownable contract:
// 1. 當合約部署時會將部署的人設定為合約擁有者。
// 2. 增加一個 onlyOwner modifier ，可以限制特定 function 只能合約擁有者執行。
// 3. 允許轉移新的合約擁有者。

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  constructor() internal { // constructor - 只有當合約被建立部署時才會執行，且只執行一次。
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
  * @return the address of the owner.
  */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  // 限制存取 - 只有合約的擁有者才可以執行 function 。
  modifier onlyOwner() { // modifier - 修飾其他 function 的一種 half-function ，通常在 function 執行前檢查一些 requirements 。
    require(isOwner());
    _;
  }

  /**
  * @return true if `msg.sender` is the owner of the contract.
  */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
  * @dev Allows the current owner to relinquish control of the contract.
  * @notice Renouncing to ownership will leave the contract without an owner.
  * It will not be possible to call the functions with the `onlyOwner`
  * modifier anymore.
  */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
  * @dev Transfers control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
