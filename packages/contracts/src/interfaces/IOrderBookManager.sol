// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OrderType, BuyOrSell, OrderFulfilled} from "../models/enums.sol";
import {Order} from "../models/structs.sol";

interface IOrderBookManager {
    function getTokenPair() external returns (address, address);

    function getMatcher() external returns (address);

    function createOrder(
        uint256 _amount,
        uint256 _minPrice,
        uint256 _maxPrice,
        OrderType _orderType,
        BuyOrSell _buyOrSell
    ) external;

    function getOrderById(
        OrderType _orderType,
        uint256 _id
    ) external returns (Order memory);

    function matchOrder(
        uint256 _orderId,
        address[] memory _matchingLpAddresses,
        uint256[] memory _matchingLpIds,
        OrderType _orderType
    ) external;
}
