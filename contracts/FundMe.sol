// SPDX-License-Identifier: MIT

// run yarn solhint contracts/*.sol to find and fix problems in code
// goals: get funds from users, withdraw funds, set a minimum funding value in usd

pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error FundMe__NotOwner();

/**
 * @title A contract for crowd funding
 * @author Yura Halcyk
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type declarations
    using PriceConverter for uint256;
    // by adding the keyword "using" we could give any uint256 within the FundMe contract the libraries functions
    // and pass the uint256 as the first parameter of that function.

    // State variables

    // constant and immutable are good gas savers if youre only setting your variables once
    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    // Events

    // Modifiers
    modifier isOwner() {
        // require(msg.sender == i_owner, "Only owner can withdraw.");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // what happens if someone sends ETH without using fund()? (so we cant keep track of their address)
    // -> recieve() and fallback()

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        // require(getConversionRate(msg.value) >= minimumUsd, "Didn't send enough!");
        // msg.value fills the first param slot for getConversionRate(). if the function took two params, then you would
        // have to put something in the brackets.
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough!"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public isOwner {
        //funderIndex = funderIndex + 1 === funderIndex++
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        // type casting msg.sender
        // msg.sender = address
        // payable(msg.sender) = payable address
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call failed");
    }

    function cheaperWithdraw() public payable isOwner {
        // read and write from memory instead of storage, and then update storage at the end
        // *mappings cant be in memory*
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    // creating getter functions for easier useability of the contract

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
