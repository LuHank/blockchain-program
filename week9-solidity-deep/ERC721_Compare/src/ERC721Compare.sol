// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "ERC721A/ERC721A.sol";
import "ERC721A/extensions/ERC721AQueryable.sol";

contract MyERC721Enumerable is ERC721Enumerable {
    constructor() ERC721("Lambogini Car", "LAMB") {
    }

    function mint(address mintOwner, uint256 tokenId) external {
        _safeMint(mintOwner, tokenId);
    }

    function mintBatch(uint256 quantity) external {
        uint256 totalSupply = totalSupply();
        for (uint i; i < quantity; i++) {
            _safeMint(msg.sender, totalSupply + 1);
        }
    }
}

contract MyAzuki is ERC721A, ERC721AQueryable {
    constructor() ERC721A("My Azuki", "MAZUKI") {

    }

    function mint(uint256 quantity) external {
        _safeMint(msg.sender, quantity);
    }
}