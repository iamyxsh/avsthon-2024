// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Liquidity} from "../models/structs.sol";

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

    function withdrawLiquidity(uint256 _groupId) external;
}
