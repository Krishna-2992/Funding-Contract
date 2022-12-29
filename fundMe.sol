//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PriceConverter.sol";
error NotOwner();

contract FundMe{
    using PriceConverter for uint;

    uint public constant MIN_USD = 5 * 1e18;
    address[] public funders;
    mapping(address => uint) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConvrsionRate() >= MIN_USD, "didn't sent enough");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }
    
    function withdraw() public onlyOwner{
        for(uint funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);
        //actually withdrawing the funds
        //Three ways for transferring money:

        //transfer
        //payable(msg.sender).transfer(address(this).balance);

        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send was not successful");

        //call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call was not successful");
    }
    modifier onlyOwner {
        // require(msg.sender == i_owner , "Sender is not the Owner");   
        if(msg.sender != i_owner){revert NotOwner();}
        _;
    }
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }
     
}
