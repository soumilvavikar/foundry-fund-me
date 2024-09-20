// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

/**
 * Custom error for not owner, not enough ETH, and call failures
 * It is good practice to have error names start with the <ContractName>__
 */
error FundMe__NotOwner();
error FundMe__NotEnoughETH();
error FundMe__CallFailed();

/**

 */
/**
 * @title The FundMe Contract - Solidity 101
 * This contract will do the following:
 * - Get funds
 * - Withdraw funds
 * - Set minimum funding value in USD
 * @author Soumil Vavikar
 * @notice NA
 */
contract FundMe {
    // This line tells that the price converter library has to be used for uint256 type of variables.
    using PriceConverter for uint256;

    uint256 public myVal = 1;

    // Minimum USD that can be transferred
    // The constant keyword helps with gas savings
    uint256 public constant MINIMUM_USD = 5e18; // 5 * 1e18

    // List of funders
    address[] public funders;

    // The variable that will be set only once can be set as immutatble. immutable keywor helps with gas savings
    address public immutable i_owner;

    // Defining AggregatorV3Interface
    AggregatorV3Interface  s_priceFeed;

    // Defining a constructor
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // Map of the funder and the amount funded
    mapping(address => uint256) public addressToAmountFunded;

    /**
     * This method will allow users to send $, have a check for minimum $ that can be sent
     * IMPORTANT:
     * - How do we send ETH to the contract
     * - Mark the function as payable to work with ETH
     */
    function fund() public payable {
        myVal = myVal + 2;

        // 1e18 wei = 1ETH
        // This statement will requirement the transaction to have more than 1 ETH being sent in the request

        // require consumes more gas over the custom error.
        // require(
        //     msg.value.getConversionRate() > MINIMUM_USD,
        //     "Didn't send enough ETH..."
        // );

        if (msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD) {
            revert FundMe__NotEnoughETH();
        }

        // What is a revert?
        // A revert will undo the action done so far, and send the remaining gas back.

        // msg.sender contains the address of the sender.
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    /**
     * This function would be used to withdraw the funds
     */
    function withdraw() public isOwner {
        // This will check if the sender of the message is owner of the contract
        // require(msg.sender == i_owner, "Withdraw operation can only be performed by the owner.");

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // To reset an array, define a new array
        funders = new address[](0);

        // withdraw the funds - 3 ways - transfer, send, and call

        // transfer - capped at 2300 gas - if fails, reverts on it own
        // payable(msg.sender).transfer(address(this).balance);

        // send - capped at 2300 gas  - if fails, just sends boolean true/false. Hence we need require to revert
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call is recommended way !!
        // call - returns 2 variables - boolean and bytes object - dataReturned
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        if (!callSuccess) {
            revert FundMe__CallFailed();
        }
    }

    /**
     * This modifier will check whether the send of the message is the owner of the contract or not
     */
    modifier isOwner() {
        // _; >> before the code here means this modifier will execute after the function logic

        // require is not gas efficient
        // require(
        //     msg.sender == i_owner,
        //     "Withdraw operation can only be performed by the owner."
        // );

        // Custom errors are more gas efficient
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }

        // _; >> after the code here means this modifier will execute before the function logic
        _;
    }

    /**
     * What happens if someones send ETH to this contract without using the fund function
     * This can be handled by recieve and/or fallback function
     * - We don't add function keyword for recieve and fallback
     * More Info : https://solidity-by-example.org/fallback/
     *
     * // Ether is sent to contract
     * //      is msg.data empty?
     * //          /   \
     * //         yes  no
     * //         /     \
     * //    receive()?  fallback()
     * //     /   \
     * //   yes   no
     * //  /        \
     * //receive()  fallback()
     * If the calldata contains the address which doesnt point to any function, fallback will be called.
     */
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    /**
     * This method will help us get the version of the AggregatorV3Interface
     * view type -
     */
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }
}

// Blockchain oracle is an external system that is used to provide real world information to the blockchain.
