// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// Why is this a library and not abstract?
// Why not an interface?

/**
 * @title The PriceConverter Library
 * @author Soumil Vavikar
 * @notice NA
 */
library PriceConverter {
    // We could make this public, but then we'd have to deploy it
    /**
     * This function helps us get the price from the AggregatorV3Interface
     */
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //(uint80 roundId, int256 price, uint256 startedAt, uint256 finishedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // This price variable will return the price of ETH in terms of USD

        return uint256(price) * 1e10;
    }

    /**
     * This function will get the conversion rate
     */
    function getConversionRate(
        uint256 etherAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 etherPrice = getPrice(priceFeed);
        // (1e18 * 1e18) / 1e18
        uint256 etherAmountInUSD = (etherPrice * etherAmount) / 1e18;
        return etherAmountInUSD;
    }

    /**
     * This method will help us get the version of the AggregatorV3Interface
     */
    function getVersion(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        return priceFeed.version();
    }
}
