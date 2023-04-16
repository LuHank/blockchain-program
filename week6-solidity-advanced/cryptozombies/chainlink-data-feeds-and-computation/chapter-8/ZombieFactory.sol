pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

// VRFConsumerbase contract 包含所有要對 Chainlink oracle 發出請求的所有程式碼。也包含所有 event logging code 。
// 要跟 Chainlink node 互動，需要知道一些變數：
// - Chainlink token contract address: 判斷我們的合約是否有足夠的 LINK 代幣來支付 gas。
// - VRF coordinator contract address: 驗證我們得到的數字實際上是真的隨機數。
// - Chainlink node keyhash: 標示要使用哪個 Chainlink node 。
// - Chainlink node fee: Chainlink 將向我們收取的費用（gas），以 LINK 代幣表示。
// 參考： https://docs.chain.link/vrf/v2/subscription/supported-networks

// 如何實作 VRFConsumerBase 合約的 constructor
// => constructor 包 constructor ， 作為 constructor 宣告的一部分
// import "./Y.sol";
// contract X is Y {
//     constructor() Y() public{
//     }
// }
// or
// constructor() VRFConsumerBase(
//     0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
//     0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
// ) public{
// }

// Chainlink VRF Contract Addresses 
// https://docs.chain.link/vrf/v2/subscription/supported-networks
// VRFConsumerBase contract
// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/VRFConsumerBase.sol

// 1. Have our `ZombieFactory` contract inherit from the `VRFConsumerBase` contract
contract ZombieFactory is VRFConsumerBase {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    // 2. Create a constructor
    constructor() VRFConsumerBase(
        0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
        0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
    ) public {

    }

    function _createZombie(string memory _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }

    function _generatePseudoRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

}
