const EthPriceOracle = artifacts.require('EthPriceOracle')

module.exports = function (deployer) {
  // deployer.deploy(EthPriceOracle)
  // 因為 EthPriceOracle.sol 原本使用 Ownable.sol 改為使用 Roles.sol ，且由 construct 可以傳入 owner address 決定 owner。
  deployer.deploy(EthPriceOracle, '0xb090d88a3e55906de49d76b66bf4fe70b9d6d708')
}