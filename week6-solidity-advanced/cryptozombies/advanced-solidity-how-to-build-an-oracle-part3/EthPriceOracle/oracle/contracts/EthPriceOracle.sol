// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
pragma solidity ^0.5.0;
// a system that provides different levels of access: owner and oracle.
// - owner: add and remove oracles
// - oracle: update the ETH price by calling the setLatestEthPrice function
// OpenZeppelin Roles library - Roles contract 參考 https://github.com/hiddentao/openzeppelin-solidity/blob/master/contracts/access/Roles.sol
import "openzeppelin-solidity/contracts/access/Roles.sol";


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
// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./CallerContractInterface.sol"; // 為了回傳 ETH price 給 caller contract
// contract EthPriceOracle is Ownable {
contract EthPriceOracle {
  // Roles is a library. For us, this means that we can attach it to the Roles.Role data type
  // the first parameter expected by the add, remove, and has functions (that is Roles storage role) is automatically passed, 
  // meaning we can use these functions to manage our roles
  // 例如 oracles.add(_oracle); // Adds `_oracle` to the list of oracles
  using Roles for Roles.Role; // Attach Roles to the Roles.Role data type
  Roles.Role private owners;  // 宣告 Roles.Role 變數 - 可以存放不只一個 address 作為 owner
  Roles.Role private oracles;
  // 可能因為非常大量的 oracles 造成 computedEthPrice 溢出 overflow
  // 例如 uint8 最大值 255 最小值 0 => 若 255 再加 1 就會變成 0 若 0 再減 1 就會變成 255
  // OpenZeppelin 提供 SafeMath library 參考 https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
  using SafeMath for uint256; // 告訴你的合約將為 uint256 使用 SafeMath ， Then, you can use SafeMath's functions- add, sub, mul, and div
  uint private randNonce = 0;
  uint private modulus = 1000;
  uint private numOracles = 0;
  uint private THRESHOLD = 0;
  mapping(uint256=>bool) pendingRequests;
  struct Response {
    address oracleAddress;
    address callerAddress;
    uint256 ethPrice;
  }
  mapping (uint256=>Response[]) public requestIdToResponse;
  event GetLatestEthPriceEvent(address callerAddress, uint id); // 紀錄誰呼叫 oracle contract
  event SetLatestEthPriceEvent(uint256 ethPrice, address callerAddress);
  event AddOracleEvent(address oracleAddress);
  event RemoveOracleEvent(address oracleAddress);
  event SetThresholdEvent (uint threshold);
  // Ownable 改為 Roles 需在 constructor 決定 owner
  constructor (address _owner) public {
    owners.add(_owner);
  }
  // 設定 new oracle
  // - 驗證 caller 是合約 owners
  // - address 還不屬於 oralces
  // - 觸發事件通知 front-end 有新的 oracle 加入
  function addOracle(address _oracle) public {
    require(owners.has(msg.sender), "Not an owner!");
    require(!oracles.has(_oracle), "Already an oracle!"); // 須注意此情況是使用 ! NOT
    oracles.add(_oracle);
    numOracles++;
    emit AddOracleEvent(_oracle); // 觸發事件通知 front-end 有新的 oracle 加入
  }

  // 避免誤刪 oracle 造成合約無用，需要追蹤 oracle 數量。
  // - 需要一個變數儲存目前 oracle 數量
  // - addOracle function 將會遞增此變數
  // - removeOracle function 
  //   - 需先判斷此變數是否大於 1
  //   - 才真正執行 oracle.remove
  //   - 遞減此變數
  function removeOracle (address _oracle) public {
    require(owners.has(msg.sender), "Not an owner!");
    require(oracles.has(_oracle), "Not an oracle!");
    // 3. Continue here
    require(numOracles > 1, "Do not remove the last oracle!");
    oracles.remove(_oracle);
    numOracles--;
    emit RemoveOracleEvent(_oracle);
  }

  function setThreshold (uint _threshold) public {
    require(owners.has(msg.sender), "Not an owner!");
    THRESHOLD = _threshold;
    emit SetThresholdEvent(THRESHOLD);
  }

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
  function setLatestEthPrice(uint256 _ethPrice, address _callerAddress, uint256 _id) public {
    require(oracles.has(msg.sender), "Not an oracle!");
    require(pendingRequests[_id], "This request is not in my pending list.");
    // make the contract work in a more decentralized manner.
    // With more oracles added, your contract expects more than one response for each request.
    // To keep track of everything, for each response, you will store 
    // - oracleAddress
    // - callerAddress
    // - ethPrice
    // 並對應 request id
    Response memory resp;
    resp = Response(msg.sender, _callerAddress, _ethPrice); // 不用 new ？
    requestIdToResponse[_id].push(resp);
    // 多少 responses 足以讓預言機計算 ETH 價格並將其傳遞給客戶端
    // 當 oracle 關閉或者網路問題，在上述問題得到解決之前，您的合約將無法滿足任何請求。
    // define a threshold => 當 responses 等於 threshold ， oracle contrac 將計算 ETH pricae 並傳給 caller 。
    // 當然，這種方法也不是萬無一失的，但它可以更好地緩解可能出現的問題。
    uint numResponses = requestIdToResponse[_id].length;
    if (numResponses == THRESHOLD) {
      // how to compute the ETH price 
      // - calculate the average of the set of responses => 並不安全只是練習用
      //   請記住，如果一些 Oracle 決定操縱價格，這種方法會使您的合約容易受到攻擊。
      //   這不是一個簡單的問題，解決方案超出了本課的範圍。
      //   - 解決此問題的一種方法是通過使用四分位數(quartiles)和四分位數間距(interquartile)來移除異常值(outliers)。
      //     quartiles 參考 https://www.mathsisfun.com/data/quartiles.html
      uint computedEthPrice = 0;
      for (uint f=0; f < requestIdToResponse[_id].length; f++) {
        // computedEthPrice += requestIdToResponse[_id][f].ethPrice; // request id 對應的 Response array 且是第 f 個 Response struct
        computedEthPrice = computedEthPrice.add(requestIdToResponse[_id][f].ethPrice);
      }
      // computedEthPrice = computedEthPrice / numResponses;
      computedEthPrice = computedEthPrice.div(numResponses);

      delete pendingRequests[_id];
      delete requestIdToResponse[_id];
      // 呼叫 caller contract - callback function 回傳 ETH price, request id 給 caller functino
      CallerContractInterface callerContractInstance;
      callerContractInstance = CallerContractInterface(_callerAddress);
      // callerContractInstance.callback(_ethPrice, _id);
      // emit SetLatestEthPriceEvent(_ethPrice, _callerAddress);
      callerContractInstance.callback(computedEthPrice, _id);
      emit SetLatestEthPriceEvent(computedEthPrice, _callerAddress);
    }
  }

}


/* 
  struct recap:
  - 宣告
    struct MyStruct {
      address anAddress;
      uint256 aNumber;
    }
  - 實體化
    MyStruct memory myStructInstance; // declare the struct
    myStructInstance = new MyStruct(msg.sender, 200); // initialize it
  - 改變值
    myStructInstance.anAddress = otherAddress
*/