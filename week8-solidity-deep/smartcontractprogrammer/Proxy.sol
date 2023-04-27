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
//   - 如果是 admin 就可以呼叫 proxy contract functions 
//   - 如果是 user 則轉到只能呼叫 implementation contract
//   - 想要 Proxy contract's admin(), implementation() 也可以在 implementation contract ，甚至想要在 implementation contract 也可以執行此兩個在 Proxy contract 的 function 。 
//     糟糕的是 implementation contract 沒有相同的 function => 只要相同的 function selector 就可以在 implementation contract 執行 Proxy contract function 。
//   - 把 funcction 複製到 implementation contract => 但會有問題是因為 function selector 都相同，仍然執行的是 Proxy contract function 而不是 implementation contract function 。
//   - 解決就是另外建立 proxy admin contract 作為 Proxy contract's admin
//     - Proxy contract's owner 執行 Proxy contract's admin(), implementation()
//     - Proxy contract's user 執行 implementation's admin(), implementation()
//   - 解決 detail
//     - IMPLEMENTATION_SLOT, ADMIN_SLOT: public -> private
//     - 增加 changeAdmin() and ifAdmin modifier
//       - 增加 _fallback() 可以讓內部呼叫 delegatecall to implementation contract
//     - 將其他外部 function 改成需 ifAdmin
// - part5: Proxy admin
//   - proxy admin contract will be the admin of proxy contract
// - Demo

contract CounterV1 {
    // address public implementation;
    // address public admin;
    uint public count;

    function inc() external {
        count += 1;
    }

    function Admin() external view returns(address) {
        return address(1);
    }

    function Implementation() external view returns(address) {
        return address(2);
    }
}

contract CounterV2 {
    // address public implementation;
    // address public admin;
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

// contract BuggyProxy {
contract Proxy {
    // address public implementation;
    // address public admin;
    // 決定儲存 address 的 slot 在哪
    // 遵循 OpenZeppelin transparent upgradeable proxy contract 存到特殊的地方
    // bytes32 public constant IMPLEMENTATION_SLOT = bytes32(
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(
        // 扣除 1 就會變隨機不可預測 => 增加碰撞攻擊難度
        uint(keccak256("eip1967.proxy.implementation")) - 1
    );
    // bytes32 public constant ADMIN_SLOT = bytes32(
    bytes32 private constant ADMIN_SLOT = bytes32(
        // 扣除 1 就會變隨機不可預測 => 增加碰撞攻擊難度
        uint(keccak256("eip1967.proxy.admin")) - 1
    );


    constructor() {
        // admin = msg.sender;
        _setAdmin(msg.sender);
    }

    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            // 若不是 admin 則導流到 _fallback() 執行 implementaion function
            _fallback();
        }
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

    // 因為 fallback() 不能為內部呼叫因此新建一個 private function _fallback
    function _fallback() private {
        _delegate(_getImplementation());
    }

    // 如果要呼叫其他 function 例如 inc() or count() 則把 request 轉到 fallback()
    fallback() external payable {
        // _delegate(implementation);
        // _delegate(_getImplementation());
        _fallback();
    }
    // msg.data 為空時會呼叫 receive()
    receive() external payable {
        // _delegate(implementation);
        // _delegate(_getImplementation());
        _fallback();
    }

    function changeAdmin(address _admin) external ifAdmin {
        _setAdmin(_admin);
    }

    // function upgradeTo(address _implementation) external {
    function upgradeTo(address _implementation) external ifAdmin {
        // require(msg.sender == _getAdmin(), "not authorized");
        // implementation = _implementation;
        _setImplementation(_implementation);
    }

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = zero address");
        // StorageSlot.getAddressSlot(SLOT) 會回傳 pointer
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        // 判斷是不是合約
        require(_implementation.code.length > 0, "not a contract");
        // StorageSlot.getAddressSlot(SLOT) 會回傳 pointer
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    // function Admin() external view returns(address) {
    function Admin() external ifAdmin returns(address) {
        return _getAdmin();
    }

    function Implementation() external ifAdmin returns(address) {
        return _getImplementation();
    }
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }
    // 獲得 storage's pointer
    // slot - pointer
    // return pinter to address slot
    // 並把回傳的 pointer 存在 storage variable
    function getAddressSlot(bytes32 slot) internal pure
        returns (AddressSlot storage r)
    {
        assembly {
            r.slot := slot
        }
    }
}

contract TestSlot {
    bytes32 public constant SLOT = keccak256("TEST_SLOT");
    function getSlot() external view returns (address) {
        return StorageSlot.getAddressSlot(SLOT).value;
    }

    function writeSlot(address _addr) external {
        // StorageSlot.getAddressSlot(SLOT) 會回傳 pointer
        StorageSlot.getAddressSlot(SLOT).value = _addr;
    }    
}

// part4-1 執行 - 把 Proxy contract's admin(), implementation() 複製到 CounterV1 並修改 return 值
// 部署: Proxy contract, CounterV1 contract
// 執行 Proxy contract's upgradeTo(CounterV1 contract address);
// Proxy Contract's admin => EOA, implementation => CounterV1 contract address
// 切換到 CounterV1 且 At Address(Proxy contract address) - 藉由 Proxy contract address 載入已部署的 CounterV1 contract interface
// CounterV1 Contract's admin => EOA, implementation => CounterV1 contract address 都沒有變
// part4-2 執行 - admin -> 執行 Proxy contract's functions, user -> 執行 implementation contract's functions
// 部署: Proxy contract, CounterV1 contract
// 執行 Proxy contract's upgradeTo(CounterV1 contract address);
// Proxy Contract's admin => EOA, implementation => CounterV1 contract address
// 切換到 CounterV1 且 At Address(Proxy contract address) - 藉由 Proxy contract address 載入已部署的 CounterV1 contract interface
// 使用部署合約的 account: CounterV1 Contract's admin => EOA, implementation => CounterV1 contract address 因為執行 Proxy contract's functions
// 使用非部署合約的 account: CounterV1 Contract's admin => address(1), implementation => address(2) 因為執行 Proxy contract's functions

// part3-1 執行 - 尚未修改 BuggyProxy
// 部署 TestSlot
// getSlot() => address(0)
// SLOT => 上面的 address(0) 儲存的地方 (slot)
// 複製 TestSlot contract address 並貼上執行 writeSlot
// getSlot() => TestSlot contract address
// SLOT 代表儲存位置且宣告為 constant 所以不會變
// part3-2 執行 - Proxy
// 部署 Proxy
// admin => EOA
// implementation => address(0) 因為還沒設定
// 部署 CounterV1
// 複製 CounterV1 contract address 並貼上執行 Proxy upgradeTo()
// implementation => CounterV1 contract address

// part1 - part2 執行
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
