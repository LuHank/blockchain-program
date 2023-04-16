// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

// caller smart contract - interact with the oracle
// - oracle smart contract address
// - function signature you want to call
// 不要 hardcode 寫死，否則將要把合約全部重新部署且修改 front-end 。
// - 定義 oracle interface (與 interface 互動範例參考最底下)
//   interface 與 contract 不同處
//   - 只宣告 functions 且無 body
//   - 不能定義 state variables
//   - 不能有 constructors
//   - 不能繼承其他合約
//   - 由於它們用於允許不同的合約相互交互，因此所有功能都必須是 external 。
// - 知道合約 address 以及 function signature 就可以呼叫
//   - function signature:
//     - function name
//     - the list of the parameters
//     - the return value(s).

//1. Import from the "./EthPriceOracleInterface.sol" file
import "./EthPriceOracleInterface.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
contract CallerContract is Ownable {
    uint256 private ethPrice;
    // 2. Declare `EthPriceOracleInterface`
    EthPriceOracleInterface private oracleInstance; // 實例化 interface 1. 宣告 interface 變數
    // start here
    address private oracleAddress;

    mapping(uint256=>bool) myRequests;

    event newOracleAddressEvent(address oracleAddress);
    event ReceivedNewRequestIdEvent(uint256 id);
    event PriceUpdatedEvent(uint256 ethPrice, uint256 id);
    function setOracleInstanceAddress(address _oracleInstanceAddress) public onlyOwner {
        oracleAddress = _oracleInstanceAddress;
        //3. Instantiate `EthPriceOracleInterface`
        // 為什麼實例化就可以找到 oracle contract ， 因為有傳入 oracle contract address 。
        // interface 好處就是不用重複把需要呼叫的外部合約程式碼複製過來
        // 你只需要建立一個 interface ，function 需參考你要呼叫的外部合約，然後實例化傳入你要呼叫的外部合約地址。
        oracleInstance = EthPriceOracleInterface(oracleAddress); // 實例化 interface 2. 實例化
        emit newOracleAddressEvent(oracleAddress); // 可以讓 front-end 知道更新 oracle address
    }

    // 更新 ETH price
    // 1. request to call the getLatestEthPrice function of the oracle
    // 2. return requestId
    // 3. Oracle fetches the ETH price from the Binance API
    // 4. Oracle executes callback function of caller contract
    // 5. callback function update ETH price in the caller contract
    // caller 無法控制何時會得到回應，需要追蹤 pending requests 。確保每次 callback function 都對應合法 request 。
    // Define the `updateEthPrice` function
    function updateEthPrice() public {
        uint256 id = oracleInstance.getLatestEthPrice(); // 回傳 requestId
        myRequests[id] = true; // 更新 request 狀態
        emit ReceivedNewRequestIdEvent(id);
    }

    // oracle 獲得 Binance API 提供的 ETH price 就會呼叫 caller contract - callback function
    // - 確保 id 是合法的
    // - 從 myRequests mapping 移除(delete)此 id
    // - 觸發事件，讓 front-end 知道 ETH price 成功更新
    // - 只允許 oracle 呼叫 callback function 
    // oracle contract (EthPriceOracle) 會藉由 interface 方式，傳入 caller contract 實例化 interface ，就可以使用 callback function 了。
    function callback(uint256 _ethPrice, uint256 _id) public onlyOracle { // oracle 呼叫 callback function 並傳入 ETH price from Bianace API, requestId
        // 3. Continue here
            require(myRequests[_id], "This request is not in my pending list.");
            ethPrice = _ethPrice;
            delete myRequests[_id]; // 將此 request 從 pending list 移除
            emit PriceUpdatedEvent(_ethPrice, _id);
    }
    modifier onlyOracle() {
      // Start here
      require(msg.sender == oracleAddress, "You are not authorized to call this function.");
      _;
    }
}

// 定義合約街口
// pragma solidity 0.5.0;
// import "./FastFoodInterface.sol"; // 1. import interface

// contract PrepareLunch {

//   FastFoodInterface private fastFoodInstance; // 2. 宣告 interface 變數

//   function instantiateFastFoodContract (address _address) public {
//     fastFoodInstance = FastFoodInterface(_address); // 3. 實體化 interface
//     fastFoodInstance.makeSandwich("sliced ham", "pickled veggies"); // 4. 呼叫 interface 的 function
//   }
// }