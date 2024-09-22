// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundContract, WithdrawContract} from "../../script/Interactions.s.sol";

/**
 * @title FundMeIntegrationTest as test class to perform integration testing of the functions in the FundMe contract
 * @author Soumil Vavikar
 * @notice NA
 */
contract FundMeIntegrationTest is Test {
    FundMe fundMe;
    // just a value to make sure we are sending enough!
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        // Here we assign some starting balance to the dummy/mock user
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundInteractions() public  {
        FundContract fundContract = new FundContract();
        fundContract.fund(address(fundMe));

        WithdrawContract withdrawContract = new WithdrawContract();
        withdrawContract.withdraw(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
