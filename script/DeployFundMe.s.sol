// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/**
 * @title This contract will help us deploy the FundMe contract
 * @author Soumil Vavikar
 * @notice NA
 */
contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();

        // The below only works on sepolia testnet and we need to provide the rpc url while running the tests or building the contract.
        // Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306 >> fetched from https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1 for Seplia Testnet
        // address priceFeedAdd = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        // FundMe fundMe = new FundMe(priceFeedAdd);

        // Hence to avoid doing that we can use Helpe Config contract to make this dynamic.
        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        vm.stopBroadcast();

        return fundMe;
    }
}
