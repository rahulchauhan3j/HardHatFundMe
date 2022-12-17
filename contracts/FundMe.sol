// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe_NotOwner();

/** @title A contract for crowd funding
 *  @author Rahul Chauhan
 *  @notice This contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */

contract FundMe {
    // Type Declaration
    using PriceConverter for uint256;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    modifier OnlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }

    constructor(address pricefeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(pricefeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD,
            "Didnt Send Enough"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public OnlyOwner {
        for (uint i = 0; i < s_funders.length; i++) {
            s_addressToAmountFunded[s_funders[i]] = 0;
        }

        s_funders = new address[](0);
        (bool callSuccess, ) = payable(i_owner).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function cheaperWithdraw() public OnlyOwner {
        address[] memory funders = s_funders;

        for (uint i = 0; i < funders.length; i++) {
            s_addressToAmountFunded[funders[i]] = 0;
        }

        s_funders = new address[](0);
        (bool callSuccess, ) = payable(i_owner).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address _funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[_funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
