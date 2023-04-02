// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Event{
    event Log(string message, uint val);
    // up to 3 index
    event IndexedLog(address indexed sender, uint val);

    function exsample() external {
        emit Log("foo", 1234);
        emit IndexedLog(msg.sender, 789);
    }

    event Message(address indexed _from, address indexed _to, string message);

    function sendMessage(address _to, string calldata message) external {
        emit Message(msg.sender, _to, message);
    }
}

// Remix Terminal
// logs
// [
// 	{
// 		"from": "0xd9145CCE52D386f254917e481eB44e9943F39138",
// 		"topic": "0xdd970dd9b5bfe707922155b058a407655cb18288b807e2216442bca8ad83d6b5",
// 		"event": "Log",
// 		"args": {
// 			"0": "foo",
// 			"1": "1234",
// 			"message": "foo",
// 			"val": "1234"
// 		}
// 	},
// 	{
// 		"from": "0xd9145CCE52D386f254917e481eB44e9943F39138",
// 		"topic": "0x919a4e0615aef45fd56105241973bd25f287f1040399e7c9f97fa2ca1c2b5174",
// 		"event": "IndexedLog",
// 		"args": {
// 			"0": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"1": "789",
// 			"sender": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"val": "789"
// 		}
// 	}
// ]
// logs
// [
// 	{
// 		"from": "0xd9145CCE52D386f254917e481eB44e9943F39138",
// 		"topic": "0xb3dbe9e9894ca2c11cb6c80bd0b0bccb9f5b41d612dbeeda0d5474de40b874fe",
// 		"event": "Message",
// 		"args": {
// 			"0": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"1": "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
// 			"2": "sendMessage test",
// 			"_from": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// 			"_to": "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
// 			"message": "sendMessage test"
// 		}
// 	}
// ]

// Etherscan
// 參考 notion 貼圖 or contract address ( 0x84fB490a1A70D888050c0f615eD0878795097517 )

// Rmiex Terminal
// [
// 	{
// 		"from": "0x84fB490a1A70D888050c0f615eD0878795097517",
// 		"topic": "0xb3dbe9e9894ca2c11cb6c80bd0b0bccb9f5b41d612dbeeda0d5474de40b874fe",
// 		"event": "Message",
// 		"args": {
// 			"0": "0x1d2B4152f1925BD0e13D40590eD52e412C78aDBd",
// 			"1": "0x7Fd8FdD7C6E1DC00D29776AF21F0D78D63d8384d",
// 			"2": "sendMessage test",
// 			"_from": "0x1d2B4152f1925BD0e13D40590eD52e412C78aDBd",
// 			"_to": "0x7Fd8FdD7C6E1DC00D29776AF21F0D78D63d8384d",
// 			"message": "sendMessage test"
// 		}
// 	}
// ]

// Etherscan
// 參考 notion 貼圖 or contract address ( 0x84fB490a1A70D888050c0f615eD0878795097517 )
