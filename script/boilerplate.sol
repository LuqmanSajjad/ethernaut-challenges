// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console2} from "forge-std/Script.sol";


contract Mallicious {
	function attack(address _target) external {
		return;
	}
}

contract Exploit is Script {
	function run() public {
		vm.startBroadcast();
		address target = vm.envAddress("INSTANCE");
		// deploy
		Mallicious attacker = new Mallicious();
		//attack
		attacker.attack(target);
		vm.stopBroadcast();
	}
}
