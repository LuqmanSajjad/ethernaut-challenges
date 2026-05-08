
## Challenge 02 Fallout
```
forge install --no-git OpenZeppelin/openzeppelin-contracts@v3.4.0
```

### Issue: Misnamed constructor 
The vulnerability in the Fallout contract is a classic example of a misnamed constructor, which was a common issue in older versions of Solidity (pre-0.4.22).
```solidity
    /* constructor */
	// 2. The constructor name is mismatch, Fallout with a '1', causing it not detected as the contructor.
	// Anyone can call this function and claim ownership
    function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
    }
```
* so we basically just need to call the Fal1out() function first, before anyone else hopefully. The exploit script imports Fallout interface instead to avoid version conflict. 

see `script/02_FalloutSolve.s.sol`.
```solidity
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
// import interface to avoid conflict
import {IFallout} from "../src/02_IFallout.sol";
```

