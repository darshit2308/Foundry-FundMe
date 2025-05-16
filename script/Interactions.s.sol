// This file is used for interactions with the FundMe contract.
// Fund script
// Withdraw script

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol"; // Fixed import path
import {FundMe} from "../src/FundMe.sol"; // Import the FundMe contract

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe contract with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        ); // this is most recently deployed contract address
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.startBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        ); // this is most recently deployed contract address
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.startBroadcast();
    }
}
