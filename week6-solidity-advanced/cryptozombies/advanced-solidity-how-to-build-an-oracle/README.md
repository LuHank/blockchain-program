# How To Build an Oracle  
smart contracts can't directly access data from the outside world through an HTTP request or something similar.  
Instead of smart contracts pull data through something called an oracle.  
Chapter 1: Settings Things Up  
    - initialize your new project  
      ```  
      npm init -y  // 產生 package.json  
      ```  
    - install the following dependencies  
      truffle, openzeppelin-solidity, loom-js, loom-truffle-provider, bn.js, and axios.  
      ```  
      npm i truffle openzeppelin-solidity loom-js loom-truffle-provider bn.js axios  
      ```  
      會產生 node_modules 資料夾以及 package-lock.json 並修改 package.json 。  
    - using Truffle to compile and deploy your smart contracts 先創建兩個簡單的 Truffle project  
      - oracle contract project using truffle  
        ```  
        mkdir oracle && cd oracle && truffle init && cd ..  
        ```  
        依據 truffle framework 產生 contracts, migrations, test 資料夾以及 truffle-config.js  
      - caller contract project using truffle  
        ```  
        mkdir caller && cd caller && truffle init && cd ..  
        ```  
        依據 truffle framework 產生 contracts, migrations, test 資料夾以及 truffle-config.js  
    - 檢視資料夾結構  
      ```  
      tree -L 2 -I node_modules  
      ```  
        .  
        ├── caller  
        │   ├── contracts  
        │   ├── migrations  
        │   ├── test  
        │   └── truffle-config.js  
        ├── oracle  
        │   ├── contracts  
        │   ├── migrations  
        │   ├── test  
        │   └── truffle-config.js  
        └── package.json  
Chapter 2: Calling Other Contracts  
Chapter 3: Calling Other Contracts- Cont'd  
Chapter 4: Function Modifiers  
Chapter 5: Using a Mapping to Keep Track of Requests  
Chapter 6: The Callback Function  
Chapter 7: The onlyOracle Modifier  
Chapter 8: The getLatestEthPrice Function  
Chapter 9: The getLatestEthPrice Function - Cont'd  
Chapter 10: The setLatestEthPrice Function  
Chapter 11: The Oracle Contract  