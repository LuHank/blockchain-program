// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import { FiatTokenV2_1 } from "./FiatTokenV2_1.sol";
import { Ownable } from "./FiatTokenV2_1.sol";

// 放在 FiatTokenV3 之後會出現錯誤: Definition of base has to precede definition of derived contract
contract Whitelistable is Ownable {
    address public whitelister;
    mapping(address => bool) internal whitelisted;

    event Whitelisted(address indexed _account);
    event UnWhitelisted(address indexed _account);
    event WhitelisterChanged(address indexed newWhitelister);

    modifier onlyWhitelister() {
        require(
            msg.sender == whitelister,
            "Whitelistable: caller is not the whitelister"
        );
        _;
    }

    modifier notWhitelisted(address _account) {
        require(
            !whitelisted[_account],
            "Whitelistable: account is whitelisted"
        );
        _;
    }

    function isWhitelisted(address _account) external view returns (bool) {
        return whitelisted[_account];
    }

    function whitelist(address _account) external onlyWhitelister {
        whitelisted[_account] = true;
        emit Whitelisted(_account);
    }

    function unWhitelist(address _account) external onlyWhitelister {
        whitelisted[_account] = false;
        emit UnWhitelisted(_account);
    }

    function updateWhitelister(address _newWhitelister) external onlyOwner {
        require(
            _newWhitelister != address(0),
            "Whitelistable: new whitelister is the zero address"
        );
        whitelister = _newWhitelister;
        emit WhitelisterChanged(whitelister);
    }
}

contract FiatTokenV3 is FiatTokenV2_1, Whitelistable {

    function transfer(address to, uint256 value) 
        external 
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        onlyWhitelister
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    function mint(address _to, uint256 _amount)
        external
        override
        whenNotPaused
        onlyWhitelister
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        require(_to != address(0), "FiatToken: mint to the zero address");
        require(_amount > 0, "FiatToken: mint amount not greater than 0");

        uint256 mintingAllowedAmount = minterAllowed[msg.sender];
        require(
            _amount <= mintingAllowedAmount,
            "FiatToken: mint amount exceeds minterAllowance"
        );

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
        emit Mint(msg.sender, _to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

}

