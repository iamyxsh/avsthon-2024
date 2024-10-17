// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error LiquidityManager__MaxPriceLowerThanMinPrice();
error LiquidityManager__AmountIsZero();
error LiquidityManager__AllowanceNotEnough();
error LiquidityManager__QuantityIsZero();
error LiquidityManager__TokenTransferFailed();

interface ILiquidityManager {
    function getToken() external returns (address);

    function depositLiquidity(
        uint256 _amount,
        uint256 _minPrice,
        uint256 _maxPrice
    ) external;

    function getLiquidtyById(
        address _liquidityProvider,
        uint256 _groupId
    ) external returns (Liquidity memory);

    function withdrawLiquidity(
        address _liquidityProvider,
        uint256 _groupId
    ) external;
}

struct Liquidity {
    uint256 quantity;
    uint256 minPrice;
    uint256 maxPrice;
}
