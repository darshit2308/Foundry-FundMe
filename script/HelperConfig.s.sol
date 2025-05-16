// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
/*
The whole contract is used to deploy the contracat on multiple chains.
We need to do 2 things:
1) Deploy mocks(mock contracts) when we are on a local anvil chain
2) Keep track of contract address across different chains
Ex) 
Sepolia ETH -> Address1
Mainnet ETH -> Address2
... Like this for all the chains

*/

import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.sol';

contract HelperConfig is Script {
    // If we are on a local anvil chain, we deploy mocks
    // Otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig; // It is a variable of type NetworkConfig
    // Now If our active netork is Sepolia , we will return getSepoliaEthConfig
    // If our active network is Anvil, we will return getOrCreateAnvilConfig
    // If our active network is Mainnet, we will return getMainnetEthConfig
    // If our active network is Goerli, we will return getGoerliEthConfig
    // If our active network is Mumbai, we will return getMumbaiEthConfig
    // If our active network is Polygon, we will return getPolygonEthConfig
    // If our active network is Optimism, we will return getOptimismEthConfig
    // If our active network is Arbitrum, we will return getArbitrumEthConfig
    // If our active network is Avalanche, we will return getAvalancheEthConfig
    // If our active network is Fantom, we will return getFantomEthConfig
    // If our active network is BSC, we will return getBscEthConfig
    // Like this we can add all the networks

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // 2000 * 10^8 = 2000000000000000000000
    struct NetworkConfig {
        address priceFeed; // Address of the price feed contract 
        // address wEth;
        // address wBtc;
    }
    constructor() { // All the networks have different chain ids
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig(); // Sepolia is the testnet of Ethereum
        } else  {
            activeNetworkConfig = getOrCreateAnvilConfig(); // Anvil is a local Ethereum node used for blockchain development and testing. It simulates a blockchain locally, allowing developers to deploy and interact with smart contracts in a controlled environment.
        } 
            activeNetworkConfig = getSepoliaEthConfig(); // Default to Sepolia
            // activeNetworkConfig = getMainnetEthConfig(); // Mainnet is the main Ethereum network
            // activeNetworkConfig = getGoerliEthConfig(); // Goerli is a testnet of Ethereum
            // activeNetworkConfig = getMumbaiEthConfig(); // Mumbai is a testnet of Polygon
        
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) { // use memory because we are not storing it in the blockchain
    // We are not storing it in the blockchain because it is needed only for the duration of the function call 
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }
    

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // price feed address
        // 1) Deploy the mock contract
        // 2) Get the address of the mock contract
        // 3) Return the address of the mock contract
        // 4) Use the address of the mock contract in the FundMe contract
        if(activeNetworkConfig.priceFeed != address(0)) { 
            return activeNetworkConfig; // If the price feed address is not 0, return the existing address, if it is 0, then run the code below
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); // number of decimals mock price feed will use , initial price value for mock price feed.
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) // address of the mock price feed contract
        });
        return anvilConfig; // return the address of the mock price feed contract

    }
    
}
