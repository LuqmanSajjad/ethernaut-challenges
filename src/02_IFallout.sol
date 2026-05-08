// Creating a minimal interface to allow interactions with challenge contract using 0.6.x
// avoiding to import the original contract which will cause conflict
pragma solidity ^0.8.13;

interface IFallout {
    function Fal1out() external payable;
	function allocate() external payable;
	function collectAllocations() external;
	function allocatorBalance(address) external view returns (uint256);
	function owner() external view returns (address payable);
}
