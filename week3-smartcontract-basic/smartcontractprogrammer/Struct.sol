// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Structs {
    struct Car { // 宣告 struct
        string model;
        uint year;
        address owner;
    }

    Car public car; // 宣告 struct 變數
    Car[] public cars; // 宣告 struct array 變數
    mapping(address => Car[]) public carsByOwner; // 宣告 struct array mapping

    function examples() external {
        Car memory toyota = Car("Toyota", 1990, msg.sender); // 賦予 struct 變數值
        Car memory lambo = Car({year: 1980, model: "Lamborghini", owner: msg.sender}); // 賦予 struct 變數值
        Car memory tesla; // 宣告 struct 變數 - default value
        tesla.model = "Tesla"; // update struct 變數 field
        tesla.year = 2010; // update struct 變數 field 
        tesla.owner = msg.sender; // update struct 變數 field

        cars.push(toyota); // struct 變數加入 struct array - push
        cars.push(lambo); // struct 變數加入 struct array - push
        cars.push(tesla); // struct 變數加入 struct array - push

        cars.push(Car("Ferrari", 2020, msg.sender)); // 也可以直接 push ，就跟上面一樣是存在 memory

        // modify struct
        Car storage _car = cars[0]; // 如果要永久改變就要存在 storage，否則如果宣告 memory 也等於沒存
        // 因為 struct 是 reference type ，只要修改 _car varaible ，原來的 cars array 就會修改了。
        _car.year = 1999;
        delete _car.owner; // delete - reset to default value

        delete cars[1]; // delete based on index - 會把所有 elements reset to default value ("", 0, 0x0000000000000000000000000000000000000000)

    }
}