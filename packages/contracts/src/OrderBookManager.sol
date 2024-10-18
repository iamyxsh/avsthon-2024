// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IOrderBookManager} from "../src/interfaces/IOrderBookManager.sol";
import {Order} from "./models/structs.sol";
import {console} from "forge-std/Console.sol";
import {OrderBookManager__AmountIsZero, OrderBookManager__TokenTransferFailed, OrderBookManager__AllowanceNotEnough, OrderBookManager__MaxPriceLowerThanMinPrice} from "./errors/EOrderBookManager.sol";
import {OrderType, BuyOrSell, OrderFulfilled} from "./models/enums.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OrderBookManager is IOrderBookManager {
    ///----------------------- State -----------------------///

    IERC20 private immutable BASE_TOKEN;
    IERC20 private immutable QUOTE_TOKEN;

    address private immutable MATCHER;

    Order[] private marketOrders;
    Order[] private limitOrders;

    ///----------------------- Constructor -----------------------///

    constructor(address _base, address _quote, address _matcher) {
        BASE_TOKEN = IERC20(_base);
        QUOTE_TOKEN = IERC20(_quote);
        MATCHER = _matcher;
    }

    ///----------------------- Getters -----------------------///

    function getTokenPair()
        external
        view
        override
        returns (address base, address quote)
    {
        base = _getBaseToken();
        quote = _getQuoteToken();
    }

    function getMatcher() external view override returns (address matcher) {
        matcher = _getMatcher();
    }

    function createOrder(
        uint256 _amount,
        uint256 _minPrice,
        uint256 _maxPrice,
        OrderType _orderType,
        BuyOrSell _buyOrSell
    ) external override {
        if (_amount == 0) {
            revert OrderBookManager__AmountIsZero();
        }
        if (_minPrice > _maxPrice) {
            revert OrderBookManager__MaxPriceLowerThanMinPrice();
        }
        IERC20 token = _buyOrSell == BuyOrSell.BUY
            ? IERC20(BASE_TOKEN)
            : IERC20(QUOTE_TOKEN);

        if (token.allowance(msg.sender, address(this)) < _amount) {
            revert OrderBookManager__AllowanceNotEnough();
        }

        Order memory order = Order({
            id: 0,
            amount: _amount,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            matchedLpAddresses: new address[](0),
            matchedLpIds: new uint256[](0),
            orderType: _orderType,
            buyOrSell: _buyOrSell,
            orderFulfilled: OrderFulfilled.NONE
        });

        if (_orderType == OrderType.MARKET) {
            order.id = marketOrders.length + 1;
            marketOrders.push(order);
        } else {
            order.id = limitOrders.length + 1;
            limitOrders.push(order);
        }
    }

    function getOrderById(
        OrderType _orderType,
        uint256 _groupId
    ) external view override returns (Order memory) {
        if (_orderType == OrderType.MARKET) {
            return _getMarketOrderById(_groupId);
        } else {
            return _getLimitOrderById(_groupId);
        }
    }

    function matchOrder(
        uint256 _orderId,
        address[] memory _matchingLpAddresses,
        uint256[] memory _matchingLpIds,
        OrderType _orderType
    ) external override {}

    ///----------------------- Helpers -----------------------///

    function _getBaseToken() internal view returns (address) {
        return address(BASE_TOKEN);
    }

    function _getQuoteToken() internal view returns (address) {
        return address(QUOTE_TOKEN);
    }

    function _getMatcher() internal view returns (address) {
        return MATCHER;
    }

    function _transferTokens(
        IERC20 token,
        address _sender,
        address _recipient,
        uint256 _quantity
    ) internal {
        bool ok = false;
        if (_sender == address(0)) {
            ok = token.transfer(_recipient, _quantity);
        } else {
            ok = token.transferFrom(_sender, _recipient, _quantity);
        }

        if (!ok) {
            revert OrderBookManager__TokenTransferFailed();
        }
    }

    function _getMarketOrderById(
        uint256 _id
    ) internal view returns (Order memory) {
        return marketOrders[_id - 1];
    }

    function _getLimitOrderById(
        uint256 _id
    ) internal view returns (Order memory) {
        return limitOrders[_id - 1];
    }
}
