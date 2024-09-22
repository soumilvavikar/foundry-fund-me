// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/**
 * @title FundMeTest as test class to test the functions in the FundMe contract
 * @author Soumil Vavikar
 * @notice NA
 */
contract FundMeTest is Test {
    FundMe fundMe;
    // just a value to make sure we are sending enough!
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // This is also fine BUT if we change how we deploy, we need to manually change the setup here as well. So to avoid that we can do whats done in the above lines of code.
        // address priceFeedAdd = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        // fundMe = new FundMe(priceFeedAdd);

        // Here we assign some starting balance to the dummy/mock user
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        console.log("Inside the testMinimumDollarIsFive method.");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        console.log("Inside the testOwnerIsMessageSender method.");

        // This will fail as owner of fundMe is FundMeTest and not us. BUT msg sender is us.
        // However, this will work again, when we setup the tests using the FundMe contract from the deploy script
        assertEq(fundMe.getOwner(), msg.sender);

        // This will fail when we setup the tests using the FundMe contract from the deploy script
        // assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        // expectRevert tells foundry that we should be expecting a failure / revert in the next line.
        vm.expectRevert();
        // The code here should execute BUT engage the revert function
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        // prank helps us send the sender of the call as we set
        // This only works in tests and in foundry
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // Stop prank whenever we don't have the need for it in the next steps.
        vm.stopPrank();

        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        assertEq(fundMe.getFunder(0), USER);
    }

    /**
     * This modifier will initiate the dummy user and fund it.
     */
    modifier fundTestUser() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public fundTestUser {
        vm.expectRevert(); // the expectRevert ignores the vm. commands and considers the next line.
        vm.prank(address(3)); // Not the owner
        fundMe.withdraw();
    }

    /**
     * NOTE: Anvil local chain sets the default gas price to ZERO. hence till now, we haven't seen any gas being charged while running these tests
     */
    function testWithdrawFromASingleFunder() public fundTestUser {
        // Get the data needed to complete this test
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Perform the action we want to test
        
        // Set the gas price
        // vm.txGasPrice(GAS_PRICE);
        // gasLeft is built in function in solidity
        // uint256 gasStart = gasleft();

        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // >> Should have costed us some gas.

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log (gasUsed);

        // Validate whether the code worked as expected.
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    function testWithdrawFromMultipleFunders() public fundTestUser {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        /**
         * As of v0.8, for addresses we can't use uint256, we have to use uint160 as uint160 has exact same number of bytes as the address.
         */

        // Create addresses for all the 10 funders
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            // we get hoax from stdcheats >>>> vm.prank + vm.deal  = hoax
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Get the balances before making the withdraw call
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Perform actual operation
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );

        uint256 totalAmountToBeWithdrawn = (numberOfFunders + 1) * SEND_VALUE;
        assert(
            totalAmountToBeWithdrawn ==
                fundMe.getOwner().balance - startingOwnerBalance
        );
    }

    function testCheaperWithdrawFromASingleFunder() public fundTestUser {
        // Get the data needed to complete this test
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Perform the action we want to test

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        // Validate whether the code worked as expected.
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    function testCheaperWithdrawFromMultipleFunders() public fundTestUser {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        // Create addresses for all the 10 funders
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Get the balances before making the withdraw call
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Perform actual operation
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );

        uint256 totalAmountToBeWithdrawn = (numberOfFunders + 1) * SEND_VALUE;
        assert(
            totalAmountToBeWithdrawn ==
                fundMe.getOwner().balance - startingOwnerBalance
        );
    }
}
