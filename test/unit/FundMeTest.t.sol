// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
//                  ----------------->     To test the code -> forge test  <-----------------     
import {Test , console} from 'forge-std/Test.sol';
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol"; // Importing the library
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // Importing the deploy script

 /* Types of Tests :

    1) Unit Test : We test a single function or a small part of the code.(like getVersion function)
    2) Integration Test : We test how our code works with other parts of the code.
    3) Forked Test : We test our code on a sumulated real environment.
    4) Staging Test : We test our code on a real environment rather than production.
    */

contract FundMeTest is Test {
    FundMe fundMe ;
    address USER = makeAddr('user'); // This is used to create a new address for testing purpose
    uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000(17 zeros) wei = 0.1 ether
    uint256 constant STARTING_BALANCE = 0.1 ether; // 1000000000000000000(17 zeros) wei = 0.1 ether
    uint256 constant GAS_PRICE = 1;
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();// creating an instance of a  deployFundMe contract
        fundMe = deployFundMe.run(); // deployFundMe is a contract (declared above) which returns a fundMe contract
        vm.deal(USER, STARTING_BALANCE); // This is used to send some ether to the user address
    }

    // Test-1
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(),5e18); // assertEq is used to identify if 2 values are same or not 
    } 

    // Test-2
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner() , msg.sender);
        /*
        msg.sender -> The one who called the function
        address(this) -> it is me (us) calling the fundme test and then, we deploy the fundme contract
        */
    }

    // Test-3
    function testPriceFeedVersionIsAccurate() public view {
    uint256 version = fundMe.getVersion();
    console.log("Version:", version);
    assertEq(version, 4);
    }

    // Test-4
    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert(); // it says , hey ! , the next line should revert(fail).It the next line does not fails , the test fails
        // It the next line fails , the test passes
        // assert -> It should revert right here !
        // uint256 cat = 1; -> If you use this line, the test will fail coz this line is correct
        fundMe.fund(); // fund function is called without sending any eth
        // If you use above line, the test will pass sincd this line is wrong
    }

    // Test-5
    function testFundUpdatesDataStructure() public { // This is used to test the fund function
        // 1) Fund the contract
        // 2) Check if the funder is in the funders array
        // 3) Check if the amount funded is correct
        // 4) Check if the funders array is not empty
        vm.prank(USER); // This is used to test the fund function , it means that the next Transaction will be sent from the USER address
        fundMe.fund{value:SEND_VALUE}(); // Means, sender is sending a particular amount (SEND_VALUE) to the contract.
        uint256 amountFunded = fundMe.s_addressToAmountFunded(USER); // s_addressToAmountFunded is a private variable in FundMe contract
        assertEq(amountFunded, SEND_VALUE); // assertEq is used to identify if 2 values are same or not
    }


    
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // This is used to test the fund function , it means that the next Transaction will be sent from the USER address
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); // putting index as 0 since we only have 1 funder in here.
        assertEq(funder,USER);
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // This modifier is used to fund the contract before testing the withdraw function
        _;
    }   

    function testOnlyOwnerCanWithdraw() public funded {// funded modifier is used to fund the contract before testing the withdraw function
        
        vm.expectRevert();
        vm.prank(USER); // This is used to test the fund function , it means that the next Transaction will be sent from the USER address
        fundMe.withdraw(); // This is used to test the withdraw function
        // If the user USER is able to withdraw the funds (means above line become true), then test fails
        // (Because only owner can withdraw the funds) 
    }
 
    function testWithdrawWitASingleFunder() public funded { // This test checks, that when the owner withdraws the funds, the balance of the fundMe contract becomes 0 and the balance of the owner becomes equal to the starting balance + startingFundMeBalance
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // balance of owner of the contract
        uint256 startingFundMeBalance = address(fundMe).balance; // balance of the fundMe contract
        // Act
        uint256 gasStart = gasleft(); // This is used to get the gas left before the transaction -> Supppose  1000
        vm.txGasPrice(GAS_PRICE); // It sets the gas price for the next transaction(s) in your test to the value of GAS_PRICE
        vm.prank(fundMe.getOwner()); // This asks the EVM to pretent that the next transaction is coming from the address of owner of contract
        fundMe.withdraw(); // The owner withdraws all the funds from the contract => startingFundMeBalance = 0 -> Cost gas -> 200
        uint256 gasEnd = gasleft(); // Left gas = 1000 - 200 = 800
        uint256 gasUsed = (gasStart - gasEnd) * (tx.gasprice); // This is used to get the gas used for the transaction -> 200 * 1 = 200
        // Number of gas units used * (gas price) = gas used in Ether or Wei.
        console.log("Gas used:", gasUsed); // This is used to get the gas used for the transaction
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0); // This is used to test the withdraw function
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // This is used to test the withdraw function
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10; // number of funders(If you want to use numbers to generate addresses, you can use uint160)
        uint160 startingFunderIndex = 1; // starting index of funders
        for(uint160 i = startingFunderIndex; i< numberOfFunders; i++){
            // vm prank new address
            // vm.deal new address
            // address ()
            hoax(address(i), SEND_VALUE); 
            // The above line performs 2 actions:
                // 1) It gives the address address(i) SEND_VALUE amount of ether
                // 2) It pretends that the next transaction is coming from the address(i)

            fundMe.fund{value: SEND_VALUE}(); // The fund function is called with SEND_VALUE amount of ether
            //now , the address(i) is the funder of the contract
        }
        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // balance of owner of the contract
        uint256 startingFundMeBalance = address(fundMe).balance; // balance of the fundMe contract
        vm.startPrank(fundMe.getOwner()); //This starts the prank and pretends that the next transaction is coming from the owner of the contract
        fundMe.withdraw(); // The owner withdraws all the funds from the contract => startingFundMeBalance = 0
        // The above line costs gas
        vm.stopPrank(); // This stops the prank

        // Assert
        assert(address(fundMe).balance == 0); // This is used to test the withdraw function
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); // This is used to test the withdraw function

    }
    function testWithdrawWithMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10; // number of funders(If you want to use numbers to generate addresses, you can use uint160)
        uint160 startingFunderIndex = 1; // starting index of funders
        for(uint160 i = startingFunderIndex; i< numberOfFunders; i++){
            // vm prank new address
            // vm.deal new address
            // address ()
            hoax(address(i), SEND_VALUE); 
            // The above line performs 2 actions:
                // 1) It gives the address address(i) SEND_VALUE amount of ether
                // 2) It pretends that the next transaction is coming from the address(i)

            fundMe.fund{value: SEND_VALUE}(); // The fund function is called with SEND_VALUE amount of ether
            //now , the address(i) is the funder of the contract
        }
        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // balance of owner of the contract
        uint256 startingFundMeBalance = address(fundMe).balance; // balance of the fundMe contract
        vm.startPrank(fundMe.getOwner()); //This starts the prank and pretends that the next transaction is coming from the owner of the contract
        fundMe.cheaperWithdraw(); // The owner withdraws all the funds from the contract => startingFundMeBalance = 0
        // The above line costs gas
        vm.stopPrank(); // This stops the prank

        // Assert
        assert(address(fundMe).balance == 0); // This is used to test the withdraw function
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); // This is used to test the withdraw function

    }

}