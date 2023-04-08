pragma solidity ^0.4.25;

// function functionName(dataType dataLocation parameterName1, dataType ParameterName2) functionVisibility {}
// dataLocation 若為 memory 代表儲存在記憶體。對所有 reference type 是必須的，例如 arrays, structs, mappings, strings 。
// function 傳入參數的方法：
// - by value: Solidity 編譯器會為這個參數值建立一個新的副本並傳入 function 。允許 function 修改其值不需擔心初始值。
// - by reference: function 會呼叫原始變數的參考。因此 function 改變接收的變數值，原本的變數值也會跟著改變。

// 慣例：參數使用 _ 命名，以與 global variabls 區別。
 
contract ZombieFactory {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    // momory by vaule
    function createZombie(string memory _name, uint _dna) {

    }

}