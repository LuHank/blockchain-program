pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

// Chainlink Data Feeds Decimals

contract PriceConsumerV3 {
  AggregatorV3Interface public priceFeed;

  constructor() public {
    priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);  // Rinkeby
  }

  function getLatestPrice() public view returns (int) {
    (,int price,,,) = priceFeed.latestRoundData(); // 回傳 310523971888 = $3,105.52
    return price;
  }

  // Start here
  function getDecimals() public view returns (uint8) {
      uint8 decimals = priceFeed.decimals();
      return decimals;
  }
}
