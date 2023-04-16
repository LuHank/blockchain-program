pragma solidity ^0.5.0;

/* 
    oracle contract acts as a bridge, enabling the caller contracts to access the ETH price feed
    - getLatestEthPrice 
    - 計算 request id 且基於安全理由必須很難被猜中。因為要使預言機更難串通和操控特定請求的價格。想生成一個隨機數。
        good-enough way: 至於此方法不安全原因可參考 lesson4-chapter-4
        uint randNonce = 0;
        uint modulus = 1000;
        uint randomNumber = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % modulus;
        randNonce: 遞增隨機數（一個只使用過一次的數字，因此我們不會使用相同的輸入參數運行相同的哈希函數兩次)
   - setLatestEthPrice

*/

pragma solidity 0.5.0;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./CallerContractInterface.sol"; // 為了回傳 ETH price 給 caller contract
contract EthPriceOracle is Ownable {
  uint private randNonce = 0;
  uint private modulus = 1000;
  mapping(uint256=>bool) pendingRequests;
  event GetLatestEthPriceEvent(address callerAddress, uint id); // 紀錄誰呼叫 oracle contract
  event SetLatestEthPriceEvent(uint256 ethPrice, address callerAddress);
  // Start here
  function getLatestEthPrice() public returns (uint256) {
      randNonce++;
      uint id = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % modulus;
      // implement a simple system that keeps tracks of pending requests
      pendingRequests[id] = true;
      emit GetLatestEthPriceEvent(msg.sender, id);
      return id;
  }
  // JavaScript component of the oracle retrieves the ETH price from the Binance public API 
  // and then calls the setLatestEthPrice, passing it the following arguments
  // - ETH price
  // - 發起請求的合約地址 caller contract address
  // - request id
  // setLatestEthPrice function
  // - only the owner can call 
  // - check whether the request id is valid
  // - remove request from pendingRequests
  function setLatestEthPrice(uint256 _ethPrice, address _callerAddress, uint256 _id) public onlyOwner {
    require(pendingRequests[_id], "This request is not in my pending list.");
    delete pendingRequests[_id];
    // 呼叫 caller contract - callback function 回傳 ETH price, request id 給 caller functino
    CallerContractInterface callerContractInstance;
    callerContractInstance = CallerContractInterface(_callerAddress);
    callerContractInstance.callback(_ethPrice, _id);
    emit SetLatestEthPriceEvent(_ethPrice, _callerAddress);
  }

}
