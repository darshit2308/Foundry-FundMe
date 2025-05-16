// Get funds from users
// withdraw funds
// Set a minimum funding value in usd

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // Importing the interface
error FundMe__NotOwner(); // These types of error names help us to know from which contract the error is coming from.
contract FundMe {
    using PriceConverter for uint256; // all uint256 will have access to this library
    uint256 public constant MINIMUM_USD = 5e18;  // using constant. this variable doesn't uses much storage space !
    address[] public s_funders ; // Stores the addresses of all  fundesr
     // Here we everywhere use 1e18 bcoz we want the smalleset of precisions in our values of ETH

    mapping(address funder => uint256 amountFunded) public s_addressToAmountFunded; // Storage variables must be named with s_ prefix
    // Storage variables are stored on the blockchain
    // Memory variables are stored in memory and are not stored on the blockchain

    address public immutable i_owner; // initialise the address of the owner
    AggregatorV3Interface private s_priceFeed; // private variable, so that no one can access it outside the contract
    constructor(address priceFeed) { // It is a constructor, and is used in order to allow the withdraw function to be called only by the owner of contract !
        i_owner = msg.sender; 
        s_priceFeed = AggregatorV3Interface(priceFeed); // priceFeed is the address of the price feed contract
    }
    // priceFeed is the adddress of the chainlink price feed contract
    // AggregatorV3Interface is the interface of the chainlink price feed contract
    // AggregatorV3Interface is used to get the price of ETH in USD. It is an interface which is used to interact with the price feed contract.
    // immutable variables cannot change their values, and be declared only inside a constructor or at declaration.

    function fund() public payable { // Function they will call to fund

        // msg.value.getConversionRate(); --> here, msg.value is passed as parameter to the getConversionRate
        // If there is another parameter in getConversionRate, then we would had passed something in getConversionRate Function.

        // Made this function public so anyone can call this function
        // payable means that the function is capable of receiving ETH (native currency of ethereum)
        // Contracts can also store funds


        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't send enough ETH"); // condition used to check amount of ether with the transaction


        // must be greater than 1e18 (Sender must send atleast 1 eth)
        // 1ETH=1e18 wei

        // Revert: Undo any action that have been done, amd send the remaining gas back .
        // Reverted transactions also consume gas !
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }
    // function getVersion() internal view returns (uint256) {
    //     return
    //         AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
    //             .version(); // Using version function to know what ABI is being used here;// developeres use this address to get the price feeds.
    // }
    /*.ORACLE */
    /* Smart contracts can't connect to external systems on their own. They use Oracle to connect !
    A blockchain oracle is a 3rd party service which that connects blockchain to real world data.
    */
    function withdraw() public onlyOwner {  // Function which owner of contract will call to withdraw money
        // Now before execution of function, modifier will be executed.
        for(uint256 funderIndex = 0 ; funderIndex < s_funders.length; funderIndex++)
        {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); // reset the array to 0 
        // actually withdrawing the funds
        // Methods -> 
        /*
            1) Transfer : If some error, throws erroe
        payable --> contract can send funds back !!!!!!
        msg.sender -> address
        payble(msg.sender) -> payble address ... If we con't write payable, smart contract won't become payable.
        */
        // payable(msg.sender).transfer(address(this).balance); // we attach the address with the total balance we need to send
        // 2) Send : It is boolean
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Transfer Failed !!");
        // 3) Call : Forward all gas or set gas, returns bool
        (bool callSuccess, /*bytes memory dataReturned */  ) = payable(msg.sender).call{value: address(this).balance}(""); // given function returns 2 things,callSuccess and dataReturned
        require(callSuccess,"Failed");
    }
    function cheaperWithdraw() public onlyOwner {  
        /*      Reading from the storage variable is more expensive than reading from memory variable        */ 
        uint256 fundersCount = s_funders.length; // length of the array
        for(uint256 funderIndex = 0 ; funderIndex < fundersCount; funderIndex++)
        {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); 
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}(""); 
        require(callSuccess,"Failed");
    }
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version(); // Using version function to know what ABI is being used here;// developeres use this address to get the price feeds.
    }
    /*

    view / Pure functions (Getters)
    */
   function getAddressToAmountFunded(address funder) external view returns (uint256) {
        return s_addressToAmountFunded[funder]; // s_addressToAmountFunded is a private variable in FundMe contract
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index]; // s_funders is a private variable in FundMe contract
        // It returns the address of the funder at the given index
        // s_funders is an array of addresses
    }
    function getOwner() external view returns (address) {
        return i_owner; // i_owner is a private variable in FundMe contract
        // It returns the address of the owner of the contract
    }
    
    modifier onlyOwner()  // This is a modifier which we can use anywhere in a function.
    {
        // require(msg.sender == i_owner , "Must be owner !!"); 
        _; // If this line was before above line, it means that first we execute the function first, then this require statement.

        if(msg.sender != i_owner)  { revert FundMe__NotOwner();}
    }
    // What if someone sends ETH to the contract without calling fund function.
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }

    
    
}
