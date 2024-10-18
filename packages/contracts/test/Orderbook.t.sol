// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderBookManager} from "../src/OrderBookManager.sol";
import {LiquidityManager} from "../src/LiquidityManager.sol";
import {IOrderBookManager} from "../src/interfaces/IOrderBookManager.sol";
import {OrderType, BuyOrSell, OrderFulfilled} from "../src/models/enums.sol";
import {Order} from "../src/models/structs.sol";
import {TestUtils} from "./utils/TestUtils.sol";

contract OrderbookTest is Test, TestUtils {
    OrderBookManager public orderBook;
    LiquidityManager public lm;

    uint256 constant amount = 10 ether;
    uint256 constant minPrice = 2000 ether;
    uint256 constant maxPrice = 3000 ether;

    function setUp() public {
        deployMockERC20Set();

        orderBook = deployOrderbookManager(address(eth), address(usdc));
        lm = deployLiquidityManager(address(usdc));

        addLiquidity(lm, amount * 3000, 0.9 ether, 1.1 ether);
    }

    function test_TokensInitialized() public view {
        (address base, address quote) = orderBook.getTokenPair();

        assertEq(base, address(eth));
        assertEq(quote, address(usdc));
    }

    function test_Matcher() public view {
        address _matcher = orderBook.getMatcher();

        assertEq(_matcher, matcher);
    }

    function test_CreateOrder() public {
        createOrder(
            orderBook,
            amount,
            minPrice,
            maxPrice,
            OrderType.MARKET,
            BuyOrSell.BUY
        );

        Order memory order = orderBook.getOrderById(OrderType.MARKET, 1);

        assertEq(order.id, 1);
        assert(order.buyOrSell == BuyOrSell.BUY);
        assert(order.orderType == OrderType.MARKET);
        assertEq(order.amount, amount);
        assertEq(order.maxPrice, maxPrice);
        assertEq(order.minPrice, minPrice);
        assert(order.orderFulfilled == OrderFulfilled.NONE);

        createOrder(
            orderBook,
            amount,
            minPrice,
            maxPrice,
            OrderType.LIMIT,
            BuyOrSell.SELL
        );

        Order memory order2 = orderBook.getOrderById(OrderType.LIMIT, 1);

        assertEq(order2.id, 1);
        assert(order2.buyOrSell == BuyOrSell.SELL);
        assert(order2.orderType == OrderType.LIMIT);
        assertEq(order2.amount, amount);
        assertEq(order2.maxPrice, maxPrice);
        assertEq(order2.minPrice, minPrice);
        assert(order2.orderFulfilled == OrderFulfilled.NONE);
    }
}
