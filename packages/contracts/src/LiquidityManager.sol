// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ILiquidityManager} from "./interfaces/ILiquidityManager.sol";
import {Liquidity} from "./models/structs.sol";
import {LiquidityManager__TokenTransferFailed, LiquidityManager__AllowanceNotEnough, LiquidityManager__QuantityIsZero, LiquidityManager__MaxPriceLowerThanMinPrice, LiquidityManager__AmountIsZero} from "./errors/ErrLiquidityManager.sol";
import {LiquidityManager__LiquidityDeposited, LiquidityManager__LiquidityWithdrawn} from "./events/EventsLiquidityManager.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Console.sol";

contract LiquidityManager is ILiquidityManager {
    ///----------------------- State -----------------------///

    IERC20 private immutable TOKEN;
    mapping(address => uint256) private totalGroupsById;
    mapping(address => mapping(uint256 => Liquidity)) private liquidityGroups;

    ///----------------------- Constructor -----------------------///

    constructor(address _tokenAddress) {
        TOKEN = IERC20(_tokenAddress);
    }

    ///----------------------- Getters -----------------------///

    function getToken() external view override returns (address) {
        return address(TOKEN);
    }

    function getLiquidtyById(
        address _liquidityProvider,
        uint256 _groupId
    ) external view override returns (Liquidity memory) {
        return _getLiquidtyById(_liquidityProvider, _groupId);
    }

    ///----------------------- Setters -----------------------///

    function depositLiquidity(
        uint256 _amount,
        uint256 _minPrice,
        uint256 _maxPrice
    ) external override {
        if (_minPrice > _maxPrice) {
            revert LiquidityManager__MaxPriceLowerThanMinPrice();
        }
        if (_amount == 0) {
            revert LiquidityManager__AmountIsZero();
        }
        if (_amount > TOKEN.allowance(msg.sender, address(this))) {
            revert LiquidityManager__AllowanceNotEnough();
        }

        _transferTokens(msg.sender, address(this), _amount);

        Liquidity memory lg = Liquidity(_amount, _minPrice, _maxPrice);

        uint256 totalLgs = _updateLiquidityGroupId(msg.sender);
        _setLiquidity(totalLgs, lg, msg.sender);

        emit LiquidityManager__LiquidityDeposited(
            msg.sender,
            totalLgs,
            _amount,
            _minPrice,
            _maxPrice
        );
    }

    function withdrawLiquidity(uint256 _groupId) external override {
        Liquidity memory lpg = _getLiquidtyById(msg.sender, _groupId);
        uint256 quantity = lpg.quantity;

        if (lpg.quantity == 0) {
            revert LiquidityManager__QuantityIsZero();
        }

        lpg.quantity = 0;
        _setLiquidity(_groupId, lpg, msg.sender);

        _transferTokens(address(0), msg.sender, quantity);

        emit LiquidityManager__LiquidityWithdrawn(msg.sender, _groupId);
    }

    ///----------------------- Helpers -----------------------///

    function _getLiquidtyById(
        address _liquidityProvider,
        uint256 _groupId
    ) internal view returns (Liquidity memory) {
        return liquidityGroups[_liquidityProvider][_groupId];
    }

    function _setLiquidity(
        uint256 _groupId,
        Liquidity memory lpg,
        address _liquidityProvider
    ) internal {
        liquidityGroups[_liquidityProvider][_groupId] = lpg;
    }

    function _updateLiquidityGroupId(
        address _liquidityProvider
    ) internal returns (uint256 totalLgs) {
        totalLgs = totalGroupsById[_liquidityProvider];
        totalGroupsById[_liquidityProvider] = totalLgs++;
    }

    function _transferTokens(
        address _sender,
        address _recipient,
        uint256 _quantity
    ) internal {
        bool ok = false;
        if (_sender == address(0)) {
            ok = TOKEN.transfer(_recipient, _quantity);
        } else {
            ok = TOKEN.transferFrom(_sender, _recipient, _quantity);
        }

        if (!ok) {
            revert LiquidityManager__TokenTransferFailed();
        }
    }
}
