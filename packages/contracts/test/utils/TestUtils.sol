// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {OrderBookManager} from "../../src/OrderBookManager.sol";
import {OrderType, BuyOrSell} from "../../src/models/enums.sol";
import {Order, Liquidity} from "../../src/models/structs.sol";
import {IOrderBookManager} from "../../src/interfaces/IOrderBookManager.sol";
import {LiquidityManager} from "../../src/LiquidityManager.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";

contract TestUtils is Test {
    MockERC20 usdc;
    MockERC20 eth;
    MockERC20 bnb;

    address public matcher = address(1);
    address public bob = address(2);
    address public alice = address(3);

    function deployMockERC20Set() internal {
        usdc = deployMockErc20();
        eth = deployMockErc20();
        bnb = deployMockErc20();

        mintTokensToUser(bob);
        mintTokensToUser(alice);
    }

    function deployLiquidityManager(
        address _token
    ) internal returns (LiquidityManager) {
        LiquidityManager lm = new LiquidityManager(_token);
        return lm;
    }

    function deployOrderbookManager(
        address _base,
        address _quote
    ) internal returns (OrderBookManager orderbook) {
        orderbook = new OrderBookManager(_base, _quote, matcher);
    }

    function deployMockErc20() internal returns (MockERC20) {
        MockERC20 mock = new MockERC20("Mock", "MCK");
        return mock;
    }

    function mintMockERC20Tokens(address _reciever, MockERC20 _token) internal {
        _token.mint(_reciever);
    }

    function mintTokensToUser(address _reciever) internal {
        mintMockERC20Tokens(_reciever, usdc);
        mintMockERC20Tokens(_reciever, eth);
        mintMockERC20Tokens(_reciever, bnb);
    }

    function addLiquidity(
        LiquidityManager lm,
        uint256 amount,
        uint256 minPrice,
        uint256 maxPrice
    ) public {
        vm.startPrank(bob);
        usdc.approve(address(lm), amount);

        lm.depositLiquidity(amount, minPrice, maxPrice);
        vm.stopPrank();
    }

    function createOrder(
        OrderBookManager orderBook,
        uint256 amount,
        uint256 minPrice,
        uint256 maxPrice,
        OrderType orderType,
        BuyOrSell buyOrSell
    ) public {
        (address base, address quote) = orderBook.getTokenPair();
        IERC20 token = buyOrSell == BuyOrSell.BUY
            ? IERC20(base)
            : IERC20(quote);

        vm.startPrank(bob);
        token.approve(address(orderBook), amount);

        orderBook.createOrder(amount, minPrice, maxPrice, orderType, buyOrSell);
        vm.stopPrank();
    }

    function withdrawLiquidity(LiquidityManager lm, uint256 id) public {
        vm.startPrank(bob);
        lm.withdrawLiquidity(id);
        vm.stopPrank();
    }
}
