// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OrderType, BuyOrSell, OrderFulfilled} from "../models/enums.sol";

event OrderBookManager__OrderCreated(
    address trader,
    uint256 id,
    uint256 amount,
    uint256 minPrice,
    uint256 maxPrice,
    OrderType orderType,
    BuyOrSell buyOrSell
);
