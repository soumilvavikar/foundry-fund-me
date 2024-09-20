// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

/**
 * @title FundMeTest as test class to test the functions in the FundMe contract
 * @author Soumil Vavikar
 * @notice NA
 */
contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        console.log("Inside the testMinimumDollarIsFive method.");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        console.log("Inside the testOwnerIsMessageSender method.");

        // This will fail as owner of fundMe is FundMeTest and not us. BUT msg sender is us.
        // assertEq(fundMe.i_owner(), msg.sender);

        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);

    }
}
