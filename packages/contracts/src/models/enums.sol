// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

enum OrderType {
    MARKET,
    LIMIT
}

enum BuyOrSell {
    BUY, // Trader deposits base token
    SELL // Trader deposits quote token
}

enum OrderFulfilled {
    NONE,
    PARTIALLY,
    FULLY
}
