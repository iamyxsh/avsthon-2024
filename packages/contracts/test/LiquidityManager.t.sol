// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LiquidityManager} from "../src/LiquidityManager.sol";
import {Liquidity} from "../src/interfaces/ILiquidityManager.sol";
import {TestUtils} from "./utils/TestUtils.sol";

contract LiquidityManagerTest is Test, TestUtils {
    LiquidityManager public lm;

    uint256 constant amount = 10 ether;
    uint256 constant minPrice = 0.9 ether;
    uint256 constant maxPrice = 1.1 ether;

    function setUp() public {
        deployMockERC20Set();

        lm = deployLiquidityManager(address(usdc));
    }

    function test_TokenInitialized() public view {
        assertEq(lm.getToken(), address(usdc));
    }

    function test_DepositLiquidity() public {
        require(usdc.balanceOf(bob) > amount);

        uint256 balance1 = usdc.balanceOf(bob);

        vm.startPrank(bob);
        usdc.approve(address(lm), amount);

        lm.depositLiquidity(amount, minPrice, maxPrice);
        vm.stopPrank();

        Liquidity memory lg = lm.getLiquidtyById(bob, 1);

        uint256 balance2 = usdc.balanceOf(bob);

        assertEq(lg.quantity, amount);
        assertEq(lg.minPrice, minPrice);
        assertEq(lg.maxPrice, maxPrice);

        assertEq((balance1 - balance2), amount);
    }

    function test_WithdrawLiquidity() public {
        require(usdc.balanceOf(bob) > amount);

        addLiquidity(lm, amount, minPrice, maxPrice);

        uint256 balance1 = usdc.balanceOf(bob);

        withdrawLiquidity(lm, 1);

        uint256 balance2 = usdc.balanceOf(bob);

        Liquidity memory lg = lm.getLiquidtyById(bob, 1);

        assertEq((balance2 - balance1), amount);

        assertEq(lg.quantity, 0);
    }
}
