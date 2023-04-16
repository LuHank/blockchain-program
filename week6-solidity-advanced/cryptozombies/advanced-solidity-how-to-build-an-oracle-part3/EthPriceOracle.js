// JavaScript component of the oracle - fetches the ETH price from the Binance API

const axios = require('axios')
const BN = require('bn.js')
const common = require('./utils/common.js')
const SLEEP_INTERVAL = process.env.SLEEP_INTERVAL || 2000
const PRIVATE_KEY_FILE_NAME = process.env.PRIVATE_KEY_FILE || './oracle/oracle_private_key'
const CHUNK_SIZE = process.env.CHUNK_SIZE || 3
const MAX_RETRIES = process.env.MAX_RETRIES || 5
// import the build artifacts
// build artifacts 包含 contract bytecode version, ABI, some internal data Truffle
// ABI describes the interface between two computer programs.
// ABI describes how functions can be called and how data is stored in a machine-readable format. 
const OracleJSON = require('./oracle/build/contracts/EthPriceOracle.json')
var pendingRequests = []

// 實例化 Oracle contract
// const myContract = new web3js.eth.Contract(myContractJSON.abi, myContractJSON.networks[networkId].address)
// networkId: 合約部署在哪一個區塊鏈網路。 Extdev is 9545242630824 。如果合約重新部署在不同網路就需要修改，所以不能寫死。
// const networkId = 9545242630824 => 不要使用 hardcode
// const networkId = await web3js.eth.net.getId()

// async function: it will return promise. call this function must use "await" function().
// await: the code stops until the promise resolves.
async function getOracleContract(web3js) {
    const networkId = await web3js.eth.net.getId() // getId is a async function.
    return new web3js.eth.Contract(OracleJSON.abi, OracleJSON.networks[networkId].address) // 回傳實例化的 Oracle Contract
}

// 呼叫 Binance API 取得 ETH/USDT price
async function retrieveLatestEthPrice () {
    const resp = await axios({
      url: 'https://api.binance.com/api/v3/ticker/price',
      params: {
        symbol: 'ETHUSDT'
      },
      method: 'get'
    })
    return resp.data.price
  }

// how your JavaScript application gets notified about new requests?
// "watch" for events. 因為 oracle will just fire an event that'll trigger an action.
// javascript watch for events (pick up that event) and push it to the pendingRequests array.
async function filterEvents (oracleContract, web3js) {
    oracleContract.events.GetLatestEthPriceEvent(async (err, event) => { // 監聽 oracle contract - GetLatestEthPriceEvent
      if (err) {
        console.error('Error on event', err)
        return
      }
    // Do something
      await addRequestToQueue(event) // 呼叫 addRequestToQueue function
    })

    oracleContract.events.SetLatestEthPriceEvent(async (err, event) => { // 監聽 oracle contract - SetLatestEthPriceEvent
      if (err) {
        console.error('Error on event', err)
        return
      }

    })
}

// - 擷取 caller contract address, request id
//   - the returnValues object access an event's return values
// - 打包 caller contract address, request id 成 object, 然後放進 pendingRequests array
async function addRequestToQueue (event) {
    const callerAddress = event.returnValues.callerAddress
    const id = event.returnValues.id
    pendingRequests.push({callerAddress, id})
}

// 想像可能會有一堆 caller contracts 傳請求給你的 oracle ， Node.js 處理 array 會有問題。
// 因為 javascript 是 single-threaded. 操作都會被擋住，除非處理中已經被完成。
// 解決辦法： 
//   - 將 array 分成更小塊 (smaller chunks)，最多 MAX_CHUNK_SIZE 。然後個別處理 chunk 。
//   - 為了簡化事情，在每個塊之後，應用程序將休眠 SLEEP_INTERVAL 毫秒。使用 while loop 實作。
async function processQueue (oracleContract, ownerAddress) {
    let processedRequests = 0 // 之後會改此變數值因此不能使用 const (常數) 宣告
    while (pendingRequests.length > 0 && processedRequests < CHUNK_SIZE) {
        // - etrieve the first element from the pendingRequest array.
        //   擷取後就會從 array 移除，因此可以使 shift() 。
        //   array.shift() : retreive the first element -> remove from array -> change array length
        // - call the processRequest function
        //    processes the request: fetches the ETH price from Binance API -> calls the oracle smart contract
        // - 遞增 processedRequests variable
        const req = pendingRequests.shift()
        await processRequest(oracleContract, ownerAddress, req.id, req.callerAddress)
        processedRequests++
    }
}

// 若發生網路故障， caller contract 將不得不從頭開始重新啟動整個過程，即使在幾秒鐘內網絡連接恢復。
// 解決辦法： retry mechanism 。另外還需要中斷 loop 的條件。
// 因為如果是 Binance API address 改變了，那就會陷入無窮迴圈。
async function processRequest (oracleContract, ownerAddress, id, callerAddress) {
    let retries = 0
    while (retries < MAX_RETRIES) {
        // Since a failed HTTP request throws an error, you'll have to wrap the code that makes the call inside of a try/catch block
        try {
            // 註： JavaScript 允許您編寫無論 try 塊內是否拋出異常都執行的程式碼，但須放在 finally 塊中。您不會在本教程中使用它。
            const ethPrice = await retrieveLatestEthPrice()
            // setLatestEthPrice 實際上會與 Binance Public API 互動
            await setLatestEthPrice(oracleContract, callerAddress, ownerAddress, ethPrice, id)
            return
        } catch (error) {
            // javascript 判斷相等需用 ===
            if (retries === MAX_RETRIES - 1) { // 迴圈跑完如果真的還是有錯誤
                await setLatestEthPrice(oracleContract, callerAddress, ownerAddress, '0', id) // ethPrice 是字串型態不是數字
                return
            }
            retries++
        }
    }
}
// 將資料發送到 oracle contract 需要進行一些處理
//   - 因為 Ethereum EVM 不支持浮點數，這意味著除法會截斷小數
//     - 解決方法是簡單地將 front-end 的數字乘以 10**n
//   - Binance API 返回 8 位小數，我們還將其乘以 10**10。
//     - 為什麼我們選擇10**10？這是有原因的：一個 ETH 是 10**18 wei。這樣，我們就可以確保不會損失任何資金。
//   - JavaScript 中的 Number 類型是 "double-precision 64-bit binary format IEEE 754 value"，它只支持 16 位小數
//     - 解決方法是使用 BN.js library (建議處理數字時一律使用 BN.js)
//     - JavaScript 是一種動態類型的語言（奇特方式：編譯器在 runtime 分析變數值並根據此值為其分配 type） => 其他語言則需先宣告變數 data type 。
async function setLatestEthPrice (oracleContract, callerAddress, ownerAddress, ethPrice, id) {
    // Start here
    ethPrice = ethPrice.replace('.', '') // 將小數點移除 例如原本 Binance API 回傳 169.87000000
    const multiplier = new BN(10**10, 10)
    const ethPriceInt = (new BN(parseInt(ethPrice), 10)).mul(multiplier)
    const idInt = new BN(parseInt(id))
    try {
      await oracleContract.methods.setLatestEthPrice(ethPriceInt.toString(), callerAddress, idInt.toString()).send({ from: ownerAddress })
    } catch (error) {
      console.log('Error encountered while calling setLatestEthPrice.')
      // Do some error handling
    }
}

// oracle starts
// - 藉由呼叫 common.loadAccount function 連接 Extdev TestNet 
// - 實例化 oracle contract
// - 監聽事件
// - return (javascript 不能 return multiple values 但可以回傳一個 object or array)
//   - client (object - app 使用來與 Extedev Testnet 互動)
//   - oracle contract instance
//   - ownerAddress (在 setLatestEthPrice 中用於指定發送交易的地址)
async function init () {
  // common.loadAccount() 連接 Extdev TestNet
  const { ownerAddress, web3js, client } = common.loadAccount(PRIVATE_KEY_FILE_NAME) // common.loadAccout() 不用 await
  const oracleContract = await getOracleContract(web3js) // 實例化 oracle contract
  filterEvents(oracleContract, web3js) // 不用 await
  return { oracleContract, ownerAddress, client }
}

// 分批處理 Queue，thread 將在每次迭代(iteration)之間休眠 SLEEP_INTERVAL 毫秒。
(async () => {
    const { oracleContract, ownerAddress, client } = await init()
    // Gracefully shut down the oracle
    // 不想要留下 dangling callback function(在 SIGINT 執行的)
    process.on( 'SIGINT', () => {
      console.log('Calling client.disconnect()')
      // 1. Execute client.disconnect
      client.disconnect()
      process.exit( )
    })
    setInterval(async () => {
      // 2. Run processQueue
      await processQueue(oracleContract, ownerAddress)
    }, SLEEP_INTERVAL)
  })()
  