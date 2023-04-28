// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";

contract MyToken is ERC20("name", "symbol", 18) {
    function mint(address _address, uint256 _amount) public {
        _mint(_address, _amount);
    }
}

// import "@openzeppelin/contracts/access/Ownable.sol";

// contract TestOz is Ownable {}
