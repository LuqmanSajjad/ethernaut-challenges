/*
https://ethernaut.openzeppelin.com/

============================== 
	03 Coin Flip level
==============================  

This is a coin flipping game where you need to build up 
your winning streak by guessing the outcome of a coin flip. 
To complete this level you'll need to use your psychic 
abilities to guess the correct outcome 10 times in a row.

  Things that might help

    See the "?" page above in the top right corner menu, section "Beyond the console"
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CoinFlip {
    uint256 public consecutiveWins;
    uint256 lastHash;
	// ## 0. this suscpiciously long number is 2^255, which is the max value in uint256
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() {
        consecutiveWins = 0;
    }

	// ## 1. we need to somehow guess the correct value 10 times in a row? 
	// ## 2. what does blockhash() do? 
	// * a function that returns the previous block hash. valid for the last 256 block (excluding current block). 
	// block not within range will return 0x00..00
    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;

		//	3. ## We can just perform the calculation before calling the flip function
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}
