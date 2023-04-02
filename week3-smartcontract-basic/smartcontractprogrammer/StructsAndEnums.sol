// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract StructsAndEnums {
    struct Shipment {
        string package;
        string state;
        address sender;
        address receiver;
        uint price;
        // bool delivered;
        Status delivered;
    }
    
    // Shipment public purchase = Shipment("Flash Drive", "Texas", 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 20, true);
    Shipment public purchase = Shipment("Flash Drive", "Texas", 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 20, Status(0));
    
    function update (string memory _package, string memory _state, 
    // address _sender, address _receiver, uint _price, bool _delivered) public{
    address _sender, address _receiver, uint _price, Status _delivered) public{
        purchase = Shipment(_package, _state, _sender, _receiver, _price, _delivered);
        getPurchase[msg.sender] = purchase;
    }

    enum Status {
        None,
        Pending,
        Shipped,
        Received
    }

    Status public orderStatus;

    function change(uint value) public {
        orderStatus = Status(value);
    }

    mapping (address => Shipment) public getPurchase;

}

// https://code.pieces.app/blog/understanding-structs-and-enums-in-solidity