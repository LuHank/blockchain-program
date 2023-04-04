// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PokomoGame {
    struct Pokomo {
        string name;
        uint attack;
        uint defense;
    }
    Pokomo public pokomo;
    Pokomo[] public pokomos;
    mapping (address => Pokomo[]) public accPokomos;

    function createPokomo(string memory _name) public {
        Pokomo memory _p = Pokomo(_name, 0, 0);
        pokomos.push(_p);
        accPokomos[msg.sender].push(_p);
    }

    function enhanceAttack() public payable {
        require(msg.value >= 0.01 ether, unicode"需至少付費 0.01 ETH 才能增加攻擊能力");
        Pokomo storage _pokomo = pokomos[0];
        _pokomo.attack += 1;
        accPokomos[msg.sender][0] = _pokomo;

        // 不同人增加攻擊力
        // 同一人不同隻 pokomo 增加攻擊力
        // code here
    }
}