// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
// Importing the DevOpsTools
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

/**
 * @title This contract will contain the fund interaction for the FundMe contract
 * @author Soumil Vavikar
 * @notice NA
 */
contract FundContract is Script {
    uint256 FUNDING_AMOUNT = 0.01 ether;

    function fund(address contractAddress) public {
        vm.startBroadcast();
        FundMe(payable(contractAddress)).fund{value: FUNDING_AMOUNT}();
        vm.stopBroadcast();

        console.log("Funds sent %s", FUNDING_AMOUNT);
    }

    function run() external {
        // Get the most recently deployed contract
        address mostRecentContract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        // Calling the fund method
        fund(mostRecentContract);
    }
}

/**
 * @title This contract will contain the withdraw interaction for the FundMe contract
 * @author Soumil Vavikar
 * @notice NA
 */
contract WithdrawContract is Script {
    function withdraw(address contractAddress) public {

        vm.startBroadcast();
        FundMe(payable(contractAddress)).withdraw();
        vm.stopBroadcast();

        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        // Get the most recently deployed contract
        address mostRecentContract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        // Calling the withdraw method
        withdraw(mostRecentContract);
    }
}
