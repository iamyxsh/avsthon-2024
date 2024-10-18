// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

event LiquidityManager__LiquidityDeposited(
    address provider,
    uint256 id,
    uint256 amount,
    uint256 minPrice,
    uint256 maxPrice
);
event LiquidityManager__LiquidityWithdrawn(address provider, uint256 id);
