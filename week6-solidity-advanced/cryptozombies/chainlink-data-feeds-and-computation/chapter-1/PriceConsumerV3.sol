pragma solidity ^0.6.7;

// DeFi dapp - 提取 ETH 並兌換等值的 USD
//  caller contract 必須知道 ETH 等於多少 USD
//      - 中心化作法： javascript request Binance API 或者任何其他公開提供價格信息的服務，然後再餵給 contract 。
//      - 去中心化作法： contract read Chainlink network

// https://data.chain.link/
// Chainlink: is a framework for decentralized oracle networks
// - Chainlink 是去中心化預言機網絡 (DON) 的框架，是一種跨多個預言機從多個來源獲取數據的方法。
// - 這個 DON 以去中心化的方式聚合數據，並將其放在智能合約的區塊鏈上（通常稱為 price reference feed 或 data feed），供我們讀取。
// - 使用 Chainlink Data Feeds 是一種在這種去中心化環境中以更便宜、更準確、更安全的方式從現實世界收集數據的方法。
//   因為來自多個來源多人的生態系統，甚至比中心化預言機還便宜。
// - Chainlink Off-Chain Reporting system: 鏈下將資料達成共識，將資料以加密方式包在交易並回報到鏈上。
//   然後製作成一個協議就像 Synthetix, Aave, and Compound

pragma solidity ^0.6.7; //1. Enter Solidity version here

//2. Create the `PriceConsumerV3`contract
contract PriceConsumerV3 { // The current version of the Chainlink aggregator interface is v3.
    
}