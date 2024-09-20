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
    function getPrice() internal  view returns (uint256) {
        // Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306 >> fetched from https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1 for Seplia Testnet
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        //(uint80 roundId, int256 price, uint256 startedAt, uint256 finishedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // This price variable will return the price of ETH in terms of USD

        return uint256(price) * 1e10;
    }

    /**
     * This function will get the conversion rate
     */
    function getConversionRate(uint256 etherAmount) internal view returns (uint256)
    {
        uint256 etherPrice = getPrice();
        // (1e18 * 1e18) / 1e18
        uint256 etherAmountInUSD = (etherPrice * etherAmount) / 1e18;
        return etherAmountInUSD;
    }

    /**
     * This method will help us get the version of the AggregatorV3Interface
     * view type -
     */
    function getVersion() internal  view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
    }
}