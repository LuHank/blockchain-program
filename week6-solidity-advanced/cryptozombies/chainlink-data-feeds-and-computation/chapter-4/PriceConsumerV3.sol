pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

/* 
擷取最新的 ETH 價格: priceFeed contract - latestRoundData function
- roundId: The round ID. Each price update gets a unique round ID.
- answer: The current price.
- startedAt: Timestamp of when the round started.
- updatedAt: Timestamp of when the round was updated.
- answeredInRound: The round ID of the round in which the answer was computed.
*/
// tuple: Solidity 建立分組句法的表達式。 
// - function 回傳值以(datatype returnVaraible1, datatype returnVaraible2, datatype returnVaraible3)
//   (datatype returnVaraible1, datatype returnVaraible2, datatype returnVaraible3) = contractName.functionName();
//   (uint80 roundId, int price, uint startedAt, uint updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
// - 若回傳值沒有要使用則留空白。
//   (datatype returnVaraible1,,) = contractName.functionName();

contract PriceConsumerV3 {
  AggregatorV3Interface public priceFeed;

  constructor() public {
    priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e); // Rinkeby
  }

  // Start here
  function getLatestPrice() public view returns (int) {
      (,int price,,,) = priceFeed.latestRoundData(); // 只取 answer 其他留空白
      return price;
  }
}
