// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

/**
 * @title FundMeTest as test class to test the functions in the FundMe contract
 * @author Soumil Vavikar
 * @notice NA
 */
contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // This is also fine BUT if we change how we deploy, we need to manually change the setup here as well. So to avoid that we can do whats done in the above lines of code.
        // address priceFeedAdd = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        // fundMe = new FundMe(priceFeedAdd);
    }

    function testMinimumDollarIsFive() public view {
        console.log("Inside the testMinimumDollarIsFive method.");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        console.log("Inside the testOwnerIsMessageSender method.");

        // This will fail as owner of fundMe is FundMeTest and not us. BUT msg sender is us.
        // However, this will work again, when we setup the tests using the FundMe contract from the deploy script
        assertEq(fundMe.i_owner(), msg.sender);

        // This will fail when we setup the tests using the FundMe contract from the deploy script
        // assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
