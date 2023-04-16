pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

// 與 data feed contracts 互動 - 需要 ETH 換算成 USD 的價格 ( ETH/USD contract )
// - address
//   - on-chain Feed-Registry: 鏈上合約，追蹤所有 feed 。
//     https://docs.chain.link/data-feeds/feed-registry
//   - contract address
//     https://docs.chain.link/data-feeds/price-feeds/addresses
//     每個你像要的資料都對應不同 contract address ，也會根據不同鏈而定 ( Ethereum 主網, Polygon 主網, 測試網 ) 。

contract PriceConsumerV3 {
  AggregatorV3Interface public priceFeed;

  constructor() public {
    // 範例是 Rinkeby 測試網，已經合併，所以改為 Sepolia 測試網。
    // priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
  }
}

