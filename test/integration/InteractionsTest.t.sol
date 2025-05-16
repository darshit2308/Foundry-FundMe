// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
//                  ----------------->     To test the code -> forge test  <-----------------
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol"; // Importing the library
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // Importing the deploy script
import {FundFundMe} from "../../script/Interactions.s.sol"; // Importing the fundMe script
import {WithdrawFundMe} from "../../script/Interactions.s.sol"; // Importing the withdrawMe script

contract InteractionTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // This is used to create a new address for testing purpose
    uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000(17 zeros) wei = 0.1 ether
    uint256 constant STARTING_BALANCE = 0.1 ether; // 1000000000000000000(17 zeros) wei = 0.1 ether
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); // deployFundMe is a contract (declared above) which returns a fundMe contract
        vm.deal(USER, STARTING_BALANCE); // This is used to send some ether to the user address
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 originalFundMeBalance = address(fundMe).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE + originalFundMeBalance, afterOwnerBalance);
    }

}
