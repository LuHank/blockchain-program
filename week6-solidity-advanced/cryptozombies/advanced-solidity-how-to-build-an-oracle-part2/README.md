# How to Build an Oracle - Part 2  
JavaScript component of the oracle fetches the ETH price from the Binance public API  
- Implement the JavaScript component of the oracle.  
- Write a simple Node.js client that interacts with the oracle.  
- To glue everything together, we'll teach you how to deploy the smart contracts and run the oracle.  
requires  
- javascript
- web3  
  Lesson 6 - App Front-ends & Web3.js  
---
Chapter 1: Getting Set Up  
Chapter 2: Listening for Events  
Chapter 3: Adding a Request to the Processing Queue  
Chapter 4: Looping Trough the Processing Queue  
Chapter 5: Processing the Queue  
Chapter 6: The Retry Loop  
Chapter 7: Using Try and Catch in JavaScript  
Chapter 8: Using Try and Catch in JavaScript- Cont'd  
Chapter 9: Working with Numbers in Ethereum and JavaScript  
Chapter 10: Returning multiple values in JavaScript  
Chapter 11: Wrapping Up the Oracle  
Chapter 12: Returning multiple values in JavaScript  
Chapter 13: Deploy the contracts  
    Truffle 課程： Deploying DApps with Truffle  
    - Generating the Private Keys  
      - caller contract, oracle contract  
        ```  
        npm install loom-js  
        node scripts\gen-key.js EthPriceOracle\oracle\oracle_private_key  
        node scripts\gen-key.js EthPriceOracle\caller\caller_private_key  
        ```  
    - Configuring Truffle  
      let Truffle know how to deploy on Extdev Testnet  
      - oracle\truffle-config.js
      - caller\truffle-config.js
    - Create the migration files  
      - EthPriceOracle\oracle\migration\2_eth_price_oracle.js  
      - EthPriceOracle\oracle\caller\2_caller_contract.js  
      ```  
      const EthPriceOracle = artifacts.require('EthPriceOracle')  
      module.exports = function (deployer) {  
      deployer.deploy(EthPriceOracle)  
      }  
      ```  
    - Updating the package.json file  
      - EthPriceOracle.sol, CallerContractInterface.sol 從 EthPriceOracle\oracle 移到 EthPriceOracle\oracle\contract  
      - cd EthPriceOracle\oracle && truffle migrate --network extdev --reset -all && cd ..\..  
      - CallerContract.sol, EthPriceOracleInterface.sol 從 EthPriceOracle\caller 移到 EthPriceOracle\caller\contract  
      - cd EthPriceOracle\caller && truffle migrate --network extdev --reset -all && cd ..\..  
      - 不用每次部署合約都輸入以上指令  
        修改 package.json - scripts  
        ```  
        "scripts": {  
          "test": "echo \"Error: no test specified\" && exit 1",  
          "deploy:oracle": "cd EthPriceOracle\oracle && truffle migrate --network extdev --reset -all && cd ..\..",  
          "deploy:caller": "cd EthPriceOracle\caller && truffle migrate --network extdev --reset -all && cd ..\..",  
          "deploy:all": "npm run deploy:EthPriceOracle\oracle && npm run deploy:EthPriceOracle\caller"  
        },  
        ```  
        npm run deploy:all  

Chapter 14: Putting Everything Together  
    - node EthPriceOracle.js  
    - node Client.js  
      ```  
      * New PriceUpdated event. ethPrice: 163140000000000000000  
      * New PriceUpdated event. ethPrice: 163200000000000000000  
      * New PriceUpdated event. ethPrice: 163020000000000000000  
      * New PriceUpdated event. ethPrice: 163000000000000000000  
      ```  
Future  
    - 當您關閉 oracle 進行升級時會發生什麼。是的，即使您將其恢復在線只需要幾分鐘，在此期間發出的所有請求都將丟失。並且沒有辦法通知應用程序特定請求尚未處理。一個解決方案是跟踪最後一個被處理的塊，並且每次 oracle 啟動時，它應該從那裡獲取它。  
    - how to make the oracle more decentralized  

