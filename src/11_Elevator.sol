/*
===== ===== ===== ===== ===== =====
	Challenge 11 Elevator
===== ===== ===== ===== ===== =====
This elevator won't let you reach the top of your building. Right?
Things that might help:

    Sometimes solidity is not good at keeping promises.
    This Elevator expects to be used from a Building.
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
		// seems like we can create a mallicious Building
        Building building = Building(msg.sender);

		// we can control the return value. We can just return `false` the first time and `true` the second time
        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}
