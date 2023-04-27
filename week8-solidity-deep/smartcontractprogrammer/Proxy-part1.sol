// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// https://solidity-by-example.org/app/upgradeable-proxy/
// Transparent upgradeable prxosy pattern
// Topics
// - part1: Intro (wrong way)
//   - Proxy contract deploy CounterV1 and upgrade to CounterV2
// - part2: Return data from fallback
// - part3: Storage for implementation and admin
//   - write any slot in the storage of the contract
//     - remove implementation, admin from implementation contract
//     - create library
//   - address for the implementation and admin
// - part4: Seperate user / admin interfaces
// - part5: Proxy admin
// - Demo

contract CounterV1 {
    uint public count;

    function inc() external {
        count += 1;
    }
}

contract CounterV2 {
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

contract BuggyProxy {
    address public implementation;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function _delegate() private {
        // 使用 delegatecall 把我們的 call 轉到 implementation contracts
        (bool ok, bytes memory res) = implementation.delegatecall(msg.data);
        require(ok, "delegatecall failed");
    }

    // 如果要呼叫其他 function 例如 inc() or count() 則把 request 轉到 fallback()
    fallback() external payable {
        _delegate();
    }
    // msg.data 為空時會呼叫 receive()
    receive() external payable {
        _delegate();
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");
        implementation = _implementation;
    }
}

// 執行
// 部署: BuggyProxy, CounterV1, CounterV2
// BuggyProxy - query implementation => get address(0)
// BuggyProxy - upgradeTo 輸入 CounterV1 contract address, query implementation => get CounterV1 contract address
// BuggyProxy - query implementation => get 0xe2899bddFD890e320e643044c6b95B9B0b84157A
// 切換到 CounterV1 contract, At Address 輸入 BuggyProxy contract address => 也就是使用 Proxy contract 呼叫 inc()
//      這樣使用原因: 使用 BuggyProxy contract's address and storage 載入 CounterV1 contract interface 
//      也就是模擬 BuggyProxyContract 使用 implementaionContractAddress.delegatecall(function selector, args)
//      At Address 按鈕：載入已發布的合約。若是想載入之前已經發佈過的智能合約，透過 Remix 介面來跟智能合約做互動，
//      則可以把合約位址複製到 Load contract from Address 欄位中，然後按下 At Address 藍色按鈕。結果會出現在 Deployed Contracts 區塊中。
// Remix 就會看到 BuggyProxy (display implementation, admin) with the CounterV1 interface loaded (display count, inc()) 雖然是顯示 CounterV1 contract address
// 新的 CounterV1 - inc => transaction sucees
// 新的 CounterV1 - count 
//   => 影片: get 0 (應該加 1 卻沒有增加)
//   => 自己: Failed to decode output: Error: data out-of-bounds (length=1, offset=32, code=BUFFER_OVERRUN, version=abi/5.5.0)
// 再次 BuggyProxy - query implementation => get 0xe2899bdDFd890E320e643044C6B95b9b0b84157B

// Problem1: 為何沒加 1 ?
//      因為在 BuggyProxy delegatecall CounterV1 contract 但會使用 BuggyProxy 的 storage
//      BuggyProxy - zero slog 是存 the address of implementation <> CounterV1 - zero slog 是存 the uint of count
//      當呼叫 inc() 會將 zero slot 加 1 結果就把 BuggyProxy - zero slot 也就是 implementation 改變了
// Solve1:
//      CounterV1, CounterV2 都加上 BuggyProxy 的所有 state variables 宣告 (implementation, admin)
// Problem2: 無法得到 count
//      因為當呼叫 count 時，會呼叫 fallback() 但 fallback() 並不會回傳值。
//      Failed to decode output: Error: data out-of-bounds (length=1, offset=32, code=BUFFER_OVERRUN, version=abi/5.5.0)
// Solve2:
//      修改 fallback() 當點擊 count 要能夠回傳值
