// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OrderFulfilled, OrderType, BuyOrSell} from "./enums.sol";

struct Liquidity {
    uint256 quantity;
    uint256 minPrice;
    uint256 maxPrice;
}

struct Order {
    uint256 id;
    uint256 amount;
    uint256 minPrice;
    uint256 maxPrice;
    address[] matchedLpAddresses;
    uint256[] matchedLpIds;
    OrderType orderType;
    BuyOrSell buyOrSell;
    OrderFulfilled orderFulfilled;
}
