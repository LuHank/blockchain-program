pragma solidity ^0.6.6;

// 建立 function 呼叫 Chainlink node
// Chainlink VRF 遵循 the basic request model
// - 請求隨機數 function
// - Chainlink node 回傳隨機數的 function
//   - Chainlink node 呼叫 VRF Coordinator 驗證隨機數
//   - VRF Coordinator 呼叫我們的 ZombieFactory contract

// 使用 VRFConsumerBase contract 內建的 function 完成上述兩個 function 
// - requestRandomness function
//   1. 檢查我們的合約是否有 LINK token 支付 Chainlink node
//   2. 傳送一些 LINK token 給 Chainlink node
//   3. 觸發 「Chainlink node 正在尋找」的事件
//   4. 為我們請求鏈上隨機數分配一個 requestId
// - fulfillRandomness function
//   1. Chainlink node 呼叫 VRF Coordinator function 並帶入一個隨機數
//   2. VRF Coordinator 檢查數字是否為隨機數
//   3. 回傳 Chainlink node 建立的隨機數及 requestId

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract ZombieFactory is VRFConsumerBase {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    bytes32 public keyHash;
    uint256 public fee;
    uint256 public randomResult;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    constructor() VRFConsumerBase(
        0x6168499c0cFfCaCD319c818142124B7A15E857ab, // VRF Coordinator
        0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
    ) public{
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 100000000000000000;

    }

    function _createZombie(string memory _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }

    // 1. Create the `getRandomNumber` function
    function getRandomNumber() public returns (bytes32 requestId) {
        return requestRandomness(keyHash, fee); // 分配 requestId並回傳
    }

    // 2. Create the `fulfillRandomness` function
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness; // 回傳 Chainlink node 建立的隨機數
    }

    function _generatePseudoRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

}
