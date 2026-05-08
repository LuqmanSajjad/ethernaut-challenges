/* == Challenge 02 Fallout ==
	Claim ownership of the contract below to complete this level.
	Things that might help
	Solidity Remix IDE
*/

// SPDX-License-Identifier: MIT

/* ## 1. A quite old solidity version is being used here: 

The vulnerability in the Fallout contract is a classic example of a misnamed constructor, which was a common issue in older versions of Solidity (pre-0.4.22).

*/
pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/math/SafeMath.sol";

contract Fallout {
    using SafeMath for uint256;

    mapping(address => uint256) allocations;
    address payable public owner;

    /* constructor */
	// 2. The constructor name is mismatch, Fallout with a '1', causing it not detected as the contructor.
	// Anyone can call this function and claim ownership
    function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function allocate() public payable {
        allocations[msg.sender] = allocations[msg.sender].add(msg.value);
    }

    function sendAllocation(address payable allocator) public {
        require(allocations[allocator] > 0);
        allocator.transfer(allocations[allocator]);
    }

    function collectAllocations() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function allocatorBalance(address allocator) public view returns (uint256) {
        return allocations[allocator];
    }
}
