// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Data locations - storage memory and calldata
// storage: variable is a state varaible.
// memory: 資料從 memory 載入
// calldata: 就像 memory ，只是 calldata 只能用在 function inputs ，且無法修改。

contract DataLocations {
    struct MyStruct {
        uint foo;
        string text;
    }

    mapping(address => MyStruct) public myStructs;

    // function examples(uint[] memory y, string memory s) external returns (MyStruct memory) { // 回傳動態 data type
    function examples(uint[] calldata y, string calldata s) external returns (uint[] memory) {
    // function inputs 宣告 calldata 並傳給另一個 function 使用的原因是節省 gas ，但須注意不能修改。
        myStructs[msg.sender] = MyStruct({foo: 123, text: "bar"}); // 想要從 mapping - myStructs 獲得資料，需先 insert data to Struct MyStruct，並提供給 mapping - myStructs.

        MyStruct storage myStruct = myStructs[msg.sender]; // 想要 modify Struct ，需先宣告一個 storage 的 MyStruct 變數，並從 mapping - myStructs 得到 Struct value。
        myStruct.text = "foo"; // modify Struct value

        MyStruct memory readOnly = myStructs[msg.sender]; // 如果只是想要讀取 Struct 資料，只需將 MyStruct 變數宣告為 memory
        readOnly.foo = 456; // 存在 memory 也可以修改，只是當 function 執行完畢，並不會儲存此次修改。
        // use storage to updata data, use memory to read data.

        // return readOnly; 

        _internal(y);

        uint[] memory memArr = new uint[](3); // 在 memory 初始化 array 。create array ，不能使用 dynamic array 且只能存在 memory。 
        memArr[0] = 234; // update first element
        return memArr;
    }

    // function _internal(uint[] memory y) private { // 如果宣告 memory ， solidity 就會複製 array 所有 elements 並 create 一個新的 array 到 memory 。
    function _internal(uint[] calldata y) private pure { // 不會 create 一個新的 array ， 直接傳原本的 y ，所以才會節省 gas 。
        uint x = y[0];
    }
}

// summary
// 載入 dynamic data => 使用 storage
// 不需儲存在 blockchain => 使用 memory
// function inputs 想要節省 gas => 使用 calldata 。無論何時傳給另一個 function 使用，可避免產生一個副本。