
### Challenge 04 | Telephone 

My Challenge Instance: 0xA9f789212bbc2b5202497F01D30a0128bEAc36e0
```solidity
contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
		// ## tx.origin is the original caller of the tx chain. 
		// Therefore it shouldn't be used for authentication purposes:
		// 		-- Anyone can make a phishing contract to authenticate themselve as us
		// If we deploy a helper contract that can call this function for us, 
		// we can fullfill this statement
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}
```
- `script/04_TelephoneSolve.s.sol`
```
forge script script/04_TelephoneSolve.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --tc TelephoneSolve --broadcast
```

- Verify
```
cast call 0xA9f789212bbc2b5202497F01D30a0128bEAc36e0 "owner()(address)" --rpc-url $RPC_URL
```
_05-05-2026-16:28_


