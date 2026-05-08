## Challenge 01 Fallback
My deployed contract:
https://sepolia.etherscan.io/tx/0x739fa830bb0d2fc557b367da1c999715a97719c53171402f4bfc9e94adef9de7

```solidity
	// 1. Solution: 
	// This is the key function. This fallback functions triggers when the CALLDATA field in tx is empty
	// to call owner = msg.sender, we first need 
	// contributions[msg.sender] > 0 // by putting some money through contribute() 
	// before sending a tx with empty calldata. 
    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
```

see `script/01_solve.s.sol`.

