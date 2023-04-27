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
    address public implementation;
    address public admin;
    uint public count;

    function inc() external {
        count += 1;
    }
}

contract CounterV2 {
    address public implementation;
    address public admin;
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

    function _delegate(address _implementation) private {
        // 使用 delegatecall 把我們的 call 轉到 implementation contracts
        // (bool ok, bytes memory res) = implementation.delegatecall(msg.data);
        // require(ok, "delegatecall failed");
        // 當點擊 count 從這裡回傳值 即使此 function 沒有 return
        // 所以要使用 assembly - OpenZeppelin's transparent upgradeable proxy 
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/Proxy.sol
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.

            // calldatacopy(t, f, s) - copy s bytes from calldata at position f to mem at position t
            // calldatasize() - size of call data in bytes
            // 從 0 位置開始的 t, 從 0 開始位置的 f, 複製資料的大小
            // 複製 calldata into 記憶體 memory 0 位置，從 calldata 在記憶體 0 位置到 calldata size 的位置。
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.

            // delegatecall(g, a, in, insize, out, outsize) -
            // - call contract at address a (implementation contract address)
            // - with input mem[in…(in+insize))
            // - providing g gas
            // - and output area mem[out…(out+outsize))
            // - returning 0 on error (eg. out of gas) and 1 on success
            // 因為上面就是從 memory 0 - calldatasize, 所以這裡也是 0, calldatasize => 基本上就是我們接收的資料
            // 因為呼叫 delegatecall 之前，我們並不知道會回傳的資料是多大，所以設定 0, 0
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            // returndatacopy(t, f, s) - copy s bytes from returndata at position f to mem at position t
            // returndatasize() - size of the last returndata
            // 將 return data 存入 memory
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                // revert(p, s) - end execution, revert state changes, return data mem[p…(p+s))
                // from memory 0 to return data size
                revert(0, returndatasize())
            }
            default {
                // 複製 return data (result) 到記憶體並手動將它回傳
                // return(p, s) - end execution, return data mem[p…(p+s))
                // from memory 0 to return data size
                // 將 return data 從 memory 取出並回傳
                return(0, returndatasize())
            }
        }

    }

    // 如果要呼叫其他 function 例如 inc() or count() 則把 request 轉到 fallback()
    fallback() external payable {
        _delegate(implementation);
    }
    // msg.data 為空時會呼叫 receive()
    receive() external payable {
        _delegate(implementation);
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
// Remix 就會看到 BuggyProxy (display implementation, admin) with the CounterV1 interface loaded (display count, inc()) 顯示的是 "BuggyProxy contract address"
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

// 升級 CounterV2
// BuggyProxy - upgradeTo 輸入 CounterV2 contract address
// 切換到 CounterV2 contract, At Address 輸入 BuggyProxy contract address => 也就是使用 Proxy contract 呼叫 inc()
// 透過 BuggyProxy 載入 CounterV2
// 再切回剛剛 透過 BuggyProxy 載入 CounterV1 ，例如剛剛計算 count = 5 => 就會出現升級 CounterV2 才有的 dec()
// 執行 dec() 可以正常扣除 1
