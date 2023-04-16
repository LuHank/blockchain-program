pragma solidity ^0.6.7;

// 我們的合約從其他外部合約拉取 price - 需要該外部合約 interface / ABI
//  - import the AggregatorV3Interface from the Chainlink GitHub repository
//    - getRoundData 和 latestRoundData 都應該顯示 "No data present" ，如果他們沒有要回報的數據，而不是返回未設置的值，這可能會被誤解為實際報告的值。
//    - import 地點
//      - GitHub
//        https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol
//      - NPM Packages
//        https://www.npmjs.com/package/@chainlink/contracts
//     - 使用的 framework (Truffle, Brownie, Remix, Hardhat) 將會決定使用 Github or NPM Packages
//  - 呼叫 Chainlink Data Feed contract - latestRoundData() 回傳我們需要的資料
// 

// Start here
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

}