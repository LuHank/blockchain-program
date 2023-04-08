pragma solidity ^0.4.25;
import "./ownable.sol";

// gas: 運行以太坊 DApp 所需支付的燃料費。
// 為了執行你的 DApp function ，使用者需購買 gas ，在以太坊就是 ETH (Ether) 。
// 執行一個 function 所需支付的 gas 取決於 DApp 邏輯的複雜度。
// 每個單獨的操作都有一個 gas cost ，大致取決於執行該操作需要多少計算資源，例如寫入 storage 比新增 2 個 integers 還貴。
// total gas cost = 執行每一個運算式加總的 gas cost 。

// 優化比其他程式語言更重要，因為使用者執行你的 DApp function 是支付實際的金錢。

// 為何需要 gas ？
//     - 以太坊就像一個大的、慢的且極其安全的電腦。當你執行一個 function ，以太坊網路上所有節點都會執行同一 function 以驗證 function 執行結果。
//       也因此才讓以太坊達到去中心化、資料不可修改且抗審查。
//     - 以太坊創始者想要確保某人因為執行無窮迴圈造成網路堵塞，用真正密集的計算霸佔所有網絡資源。
//     - 所以交易不是免費的，使用者必須為運算時間和 storag 付費。
// 在以太坊上運行像魔獸世界遊戲是無意義的，因為 gas 肯定非常高。
// 之後課程將會詳細討論您希望在 Loom 網路和以太坊主網上部署哪些類型的 DApp。

// unit 類型區分為 uint8, uint16, uint32, etc 。 使用 uint8 並不會幫你節省 gas ，因為無論 uint 大小如何，Solidity 都會保留 256 位的存儲空間。
// 不過有一個例外。如果一個 struct 中有多個  uint，盡可能使用較小的 uint ， Solidity 會把這些變數打包在一起以佔用更少的儲存空間。
// 因為可以最小化儲存空間，所以需要把較小或者相同 data types 放在一起。
// gas: structA{uint a; uint b; uint c;} > structB{uint32 a; uint32 b; uint c;} => 因為 uint = uint256
// gas: structA{uint c; uint32 a; uint32 b;} < structB{uint32 a; uint c; uint32 b;} => 因為 structA 占用兩個 slot 但 structB 占用三個 slot 。

// 增加兩個特性： level, readyTime ，用來實作殭屍餵食冷卻時間，也就是隔多久才能餵食。

contract ZombieFactory is Ownable {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
        // 相同 data types 打包在一起，比 uint(256) 還節省 gas 。
        uint32 level;
        uint32 readyTime; // 此資料型態大小儲存 timestamp 已經足夠了。
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
