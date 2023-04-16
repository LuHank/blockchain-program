// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// 訊息可以在鏈下(Metamask)簽署，然後在鏈上使用智能合約驗證。
/*
使用 Solidity 驗證簽章流程：
1. hash(message)
2. signer = sign(hash(message), private key) | offchain - using your wallet (而不是在 smart contract)
3. ecrecover(hash(message), signature) == signer (使用 smart contract)
*/

// 使用一個 function 傳入 message signatur, signer 驗證簽章，然後使用另外 internal function 來驗證。

// js 可參考 https://solidity-by-example.org/signature/

contract VerifySig {
    // 1. signer: 期望 ecrecover 回傳的地址
    // 2. 我們要簽名的 message
    // 3. 簽章
    // 驗證 _message 簽章
    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        // recover signature 並與 _signer 比對
        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message) public pure returns(bytes32) {
        return (keccak256(abi.encodePacked(_message)));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        // 簽名是通過使用以下格式簽署 keccak256 哈希生成的
        // "\x19Ethereum Signed Message\n" + len(msg) + msg
        // len(msg) = 32 => 因為 _messageHash 為 32 bytes
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32", 
            _messageHash));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
        // 把簽章分成 3 個部分
        // r, s 是用於數字簽章的加密參數
        // v 是 Ethereum 獨有的東西
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        // recover 會回傳針對 message 進行簽章的簽名的 address
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        // 檢查確保簽章長度為 65 bytes (不含 0x 共 130 碼) ， 因為 r + s + v = 32 bytes + 32 bytes + 1 bytes(uint8) 。
        require(_sig.length == 65, "invalid signature length");

        // _sig is a dynamic data, 因為它有變數長度，對於 dynamic data types ，第一個 32 bytes 儲存了資料(此處為簽章)的長度。
        // _sig 不是真實的 signature， 它是一個指針指到 signature 儲存在記憶體的位置。
        assembly {
            // 將會我們提供的 input ，從其指針載入 32 bytes 。
            r := mload(add(_sig, 32)) // 跳過第一個 32 bytes ， 因為那是儲存資料的長度，下一個 32 bytes 就是 r 了。
            s := mload(add(_sig, 64)) // 跳過第一個以及第二個 32 bytes, 就是 s 了。
            v := byte(0, mload(add(_sig, 96))) // 跳過前三個 32 bytes, 然後只需取第 1 個 bytes 。
        }

        // 因為 returns 已經指明要回傳的變數名稱，所以 Solidity 會自己去抓，不用再寫 return 。
        // return (r, s, v) 
    }
}

// Remix 部署與執行
// 1. 執行 getMessageHash("secret message") 回傳 bytes32 _messageHash
//    0x9c97d796ed69b7e69790ae723f51163056db3d55a7a6a82065780460162d4812
//    => 使用 Meatamask 針對此 bytes32 message 進行簽名
//      - 打開瀏覽器並按 F12 然後切換到 console
//      - 開啟 Metamask: 輸入 ethereum.enable() => 將會回傳 promise ，若 promise state = fulfilled 代表開啟 Metamask 正常
//      - 開啟 promise result => 得到 account(address)
//        "0x1d2b4152f1925bd0e13d40590ed52e412c78adbd"
//      - 宣告 account = "0x1d2b4152f1925bd0e13d40590ed52e412c78adbd" => 將會使用此地址針對 message 進行簽名
//      - 宣告 hash = "0x9c97d796ed69b7e69790ae723f51163056db3d55a7a6a82065780460162d4812" (沒加雙引號會被轉成十進位)
//      - 輸入 ethereum.request({method: "personal_sign", params: [account, hash]})
//      - 跳出 Metamask 請求簽署 => 簽署
//      - 簽完名會回傳 promise => 打開 promise result 就會找到 signature
//        0x3eec430cd4760143e893c8174a1ec49f7270d0a8e87b5fd02358518f5d304d6d762e87e5783192f4fb0db851f73ce3b2a0cf1290bff0b95748545af9916938c41c
// 2. 執行 getEthSignedMessagHash(_messageHash) 
//    _messageHash = 0x9c97d796ed69b7e69790ae723f51163056db3d55a7a6a82065780460162d4812
//    => 回傳 _ethSignedMessageHash (0x95a786464acc06fafc0d46036515722ec35acb840ecc291f251e086ebfeb9099)
// 3. 執行 recover(_ethSignedMessageHash, signature from browser console)
//    recover(0x95a786464acc06fafc0d46036515722ec35acb840ecc291f251e086ebfeb9099, 0x3eec430cd4760143e893c8174a1ec49f7270d0a8e87b5fd02358518f5d304d6d762e87e5783192f4fb0db851f73ce3b2a0cf1290bff0b95748545af9916938c41c)
//    => 回傳回傳針對 message 進行簽章的簽名的 address 0x1d2B4152f1925BD0e13D40590eD52e412C78aDBd
//    應該要與 browser console 的 address 0x1d2b4152f1925bd0e13d40590ed52e412c78adbd 比對會一樣
// 4. 執行 verify(address from browser console, "secret message", signature from browser console)
//    => 會回傳 true
// 5. 修改成 "secret messages" 就會變 false ，再跑一遍 step1 - step3 會發現 address 會與 brwoser console address 不一樣。

/* conclusion
 - sring _message -> getMessageHash -> bytes32 _messageHash 
 - bytes32 _messageHash -> Metamask 簽名 -> signature 
 - bytes32 _messageHash -> getEthSignedMessageHash -> bytes32 _getEthSignedMessageHash 
 - bytes32 _getEthSignedMessageHash, bytes signature -> recover 得到 address
 - address, string _message, signature -> verify -> bool true (的確是由 address 簽署的)
*/