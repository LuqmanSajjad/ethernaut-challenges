// SPDX-License-Identifier: MIT

/*
===== ===== ===== ===== ===== 
	Level 06 - Delegation 
===== ===== ===== ===== ===== 

The goal of this level is for you to claim ownership of the instance you are given.

  Things that might help

    Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain libraries, and what implications it has on execution scope.
    Fallback methods
    Method ids

## DelegateCall:
	1. Copies calldata to the target code, 
	2. execute target's bytecode
	3. writes result into caller's storage slot
	4. returns success + returndata

	additional note;
		- address(this) is the caller's address (original contract)
		- 
		
	why delegateCall? 
		* reduce bytecode size, 
		* modular architecture

## Security Implications
	1. storage collision
	2. arbitary code exec
		- if target addr is user-controlled
	3. privesc
		- run with caller's permission
	4. ?? initialization bugs

## other resources:
- established proxy std: eip-1967

0x5055FA07c29bE69Ae381eF384B0633f89bCD880A
*/

pragma solidity ^0.8.0;

contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

	// They deployed two contracts 
	// 1. Delegation (this contract) 
	// 2. Delegate 
    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool result,) = address(delegate).delegatecall(msg.data);
        if (result) {
            this;
        }
    }
}
