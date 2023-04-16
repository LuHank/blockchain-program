pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

// Chainlink documentation basics tutorial
// https://docs.chain.link/getting-started/conceptual-overview
// - price feeds 如何在幕後運作
// - 設定 DON
// - out-of-the-box 開箱即用預言機服務
// - 讓 Chainlink Data Feeds 更加生動
// - work with Truffle, Hardhat, Front Ends, DeFi
// - 運用  Truffle Starter Kit, Hardhat Starter Kit, and Brownie Starter Kit (Chainlink Mix) 撰寫更複雜 smart contract
//   - Truffle Starter Kit: https://github.com/smartcontractkit/truffle-starter-kit
//   - Hardhat Starter Kit: https://github.com/smartcontractkit/hardhat-starter-kit
//   - Brownie Starter Kit (Chainlink Mix) : https://github.com/smartcontractkit/chainlink-mix

contract PriceConsumerV3 {
  AggregatorV3Interface public priceFeed;

  constructor() public {
    priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e); // Rinkeby
  }

  function getLatestPrice() public view returns (int) {
    (,int price,,,) = priceFeed.latestRoundData();
    return price;
  }

  function getDecimals() public view returns (uint8) {
    uint8 decimals = priceFeed.decimals();
    return decimals;
  }
}
