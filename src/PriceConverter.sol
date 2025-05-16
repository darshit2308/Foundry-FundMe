//  THIS IS GOUNG TO BE A LIBRARY
// It is sane as a contracts, only difference is that it does not contain state variables and sender can't send ETH

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// remmappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/"]

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        /* We require 2 things: 
        1) Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        2) ABI
        
        */
        // For different testnets, there are different addresses.To change it (Eg. Chainlink), visit chainlink documentations.
        // The above function gives the latest price feed.
        (, int256 price, , , ) = priceFeed.latestRoundData(); // it is uint256 because some price fees could be -ve.
        // priceFeedDate -> Gives the latest price data .
        // price -> It is price of ETH in terms of USD .
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount, AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Convets the Eth to dollars
        uint256 ethPrice = getPrice(priceFeed); // Getting Price of 1Eth in USD
        // 1000000000000000000 * 1000000000000000000 = 1000000000000000000000000000000000000
        // Note : There are no decimals in solidity, so we multiply first , then divide
        uint256 dolarPrice = (ethPrice * ethAmount) / 1e18; // Converting ETH to USD  , above statement shows why we divide 1e18
        return dolarPrice;
    }

    
}
