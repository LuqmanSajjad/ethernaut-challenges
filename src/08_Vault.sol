/*
===== ===== ===== ===== ===== 
	Level 08 - Vault 
===== ===== ===== ===== ===== 
>> Unlock the vault to pass the level!
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
// No such thing as secret in this network. All is publicly available to read through bytecod.
// in evm storage data is stored as 32 byte slots. from right to left.
// Slot number starts with 0
// first variable is bool and second is byte32 password
    bool public locked;
    bytes32 private password;

    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}
