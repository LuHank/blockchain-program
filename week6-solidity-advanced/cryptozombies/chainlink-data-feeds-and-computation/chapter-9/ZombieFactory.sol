pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

// 還需要
// - 定義 keyhash, fee 並初始化
// - randomResult: 儲存 Chainlink VRF 回傳值
// Chainlink VRF Contract Addresses 
// https://docs.chain.link/vrf/v2/subscription/supported-networks

contract ZombieFactory is VRFConsumerBase {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    // 1. Define the `keyHash`, `fee`, and `randomResult` variables. Don't forget to make them `public`.
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
      // 2. Fill in the body
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 100000000000000000;
    }

    function _createZombie(string memory _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }

    function _generatePseudoRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

}
