pragma solidity ^0.6.6;

// Chainlink VRF Introduction (https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number)
// - 使用區塊鏈以外的隨機數(Chainlink Oracle - Chainlink Verifiable Randomness Function (Chainlink VRF)) 取代 The pseudo-random DNA 
// - Chainlink VRF 包括鏈上驗證合約，以加密方式證明合約獲得的隨機數確實是隨機的。
// - 因為鏈上機制的所有部分在設計上都是確定性的，包括我們的哈希函數。所以使用 keccak256 會有些 issues 。
/* basic request model 基本請求模型
   1. call contract 發出交易請求 (callee contract or oracle contrac 觸發事件)
      callee contract 被呼叫的合約向 Chainlink node 發出請求，Chainlink node 由智能合約和對應的鏈下節點組成。
   2. 鏈下 Chainlink node 監聽事件 (請求細項紀錄在事件)
      當 Chainlink node 收到請求時，智能合約發出交易：發出一個特定的事件，相應的 Chainlink 節點訂閱/尋找。
   3. 由 Chainlink 發出第二次交易 (把資料回傳鏈上)
      Chainlink oracle 處理請求(隨機數或資料請求)並回傳資料或者計算給 callee contract 。或者響應另一個合約(middle)發出 response 給 callee contract 。
      - middle contract 通常為 oracle contract 。
      - 第二次發出交易。
   因此 basic request model 是兩次交易，至少需要兩個區塊才可完成。
   分兩次交易的重要性：因為對隨機性或數據請求的暴力攻擊會受到限制，並且如果不讓攻擊者付出高昂的 gas 費用就不可能破解。
*/
/* gas = transaction gas + oracle gas (LINK or Chainlink token) */
// data feed 
// - 是向一整組的 Chainlink node 發出請求不是只有一個
// - 但只有一個實體會對整個網路敲定此請求
// - 贊助： Aave, Compound, Synthetix 等等
// - 整個生態團隊運作降低交易成本

/* Chainlink 幕後黑手
   Chainlink VRF 使用 basic request model 還有一個額外好處：
   因為來自 Chainlink VRF node 的隨機數有鏈上加密證明，我們可以安全的使用單一 Chainlink VRF node 。
   簡單說，
   - 智能合約請求的隨機數是藉由 Chainlink oracle 使用唯一 id 產生的 hash 。
   - Chainlink 節點使用該哈希值和自己的密鑰生成隨機數。
   - 然後帶著加密證明回傳到鏈上合約 (VRF Coordinator)。
   - VRF Coordinator 鏈上合約使用公鑰驗證帶著加密證明的隨機數。
   - 依靠簽名和證明驗證功能，這使合約使用隨機數，也是由運行合約本身的相同鏈上環境驗證。
   其他 function 參考 https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/VRFCoordinator.sol
*/
/* 
  - 與 Chainlink node 合約互動
    - Github
    - NPM
  - 繼承 VRFConsumerbase contract code 機制並觸發事件
  - 定義 Chainlink 將 callback 的 function 。
  範例參考 https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number
/* 
DNA 每次輸入一樣的字串回傳的隨機樹都是相同的，這不是真正的隨機數。
uint(keccak256(abi.encodePacked(_str)))
如何修改？
- 天真方法一： 使用 global variables , msg.sender, block.difficulty, and block.timestamp 讓隨機數較難預測
  例如： msg.sender, block.difficulty, and block.timestamp
  但這些都預測的到，所以才說區塊鏈上的資料都是確定性的。使用這種隨機數將導致漏洞產生。
  - msg.sender: sender 會知道
  - block.difficulty: 直接受礦工影響
  - block.timestamp: 可預測的
- 天真方法二： 採用鏈下 API call ，因為如果該服務出現故障、被賄賂、被黑客入侵或以其他方式出現，您可能會取回損壞的隨機數。
*/


// 1. Import the "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol" contract
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract ZombieFactory {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    function _createZombie(string memory _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }

    function _generatePseudoRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

}
