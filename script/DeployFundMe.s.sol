// SPDX-License-Identitifier: MIT

pragma solidity ^0.8.26;
// It is a script used to deploy the fundme contract on the blockchain.

import {Script} from 'forge-std/Script.sol';
import {FundMe} from '../src/FundMe.sol';
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployFundMe is Script {
    
    function run() external returns (FundMe) {

        // Before startBroadcast -> Not a real Transaction (No gas fee)
        HelperConfig helperConfig = new HelperConfig(); // writing this line before startBroadcast to avoid gas fee
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
         // After startBroadcast ->  A real Transaction
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // This is the address of the price feed contract
        vm.stopBroadcast();
        return fundMe; // This is the address of the fundme contract
    }
}