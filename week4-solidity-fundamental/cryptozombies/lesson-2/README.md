# week4 - cryptozombies lesson 2
- chapter-2: 多人遊戲 (帳號擁有的殭屍 ID, 帳號擁有的殭屍數量)
- chapter-3: _createZombie private function - 儲存帳號擁有的殭屍 ID, 儲存帳號擁有的殭屍數量
- chapter-4: createRamdomZombie public function - 限制一個帳號只能生成一隻殭屍
  補充： Solidity 無法比較原生字串，須把兩個字串經過 keecak256 hash 後比較。
- chapter-5: ZombieFeeding contract - 繼承
- chapter-6: 拆成兩個 sol 檔案則繼承需使用 import sol
- chapter-7: feedAndMultiply - 賦予殭屍餵食及繁殖能力
  補充： 
    1. function 內操作 struct, arry 才需要標示清楚 data location (storage, memory, calldata)
    2. 其他狀況不需特別標示，例如 宣告變數 在 function 外面其預設就會是 storage ，宣告變數在 functions 內部其預設就會是 memory 。 
- chapter-8: feedAndMultiply - 生成新 DNA (殭屍 DNA + 餵食 DNA) 並創建新殭屍
  補充：確保餵食的 DNA 只有 16 digits 。
- chapter-9: _createZombie function 修改 visibility 。 改成可被繼承合約呼叫的 internal 。 (原為 private )
- chapter-10: 餵食僵屍的食物 - CryptoKitties - 利用 interface 與其他合約互動。
- chapter-11: 實作利用 interface 與其他合約互動 - 宣告 interface 變數並指定 CryptoKitties 合約地址
- chapter-12: 呼叫 CryptoKitties 合約的 getKitties function 得到 CryptoKitties 並餵食給殭屍建立新殭屍
- chapter-13: 加入殭屍物種為 kitty
- chapter-14: 前端如何與合約互動