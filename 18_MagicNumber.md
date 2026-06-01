## 18 Magic Number 
This level is fundamentally about:
* EVM internals
* runtime bytecode vs creation bytecode
* stack/memory operations
* hand-crafted opcodes

#### Author note
```
To solve this level, you only need to provide the Ethernaut with a Solver, a contract that responds to whatIsTheMeaningOfLife() with the right 32 byte number.

Easy right? Well... there's a catch.

The solver's code needs to be really tiny. Really reaaaaaallly tiny. Like freakin' really really itty-bitty tiny: 10 bytes at most.

Hint: Perhaps its time to leave the comfort of the Solidity compiler momentarily, and build this one by hand O_o. That's right: Raw EVM bytecode.

Good luck!
```

- Challenge Contract
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicNum {
    address public solver;

    constructor() {}

    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
    */
}
```

### Solution:
* Deploy a contract that
    + whatIsTheMeaningOfLife() returns number 42 in 32 byte 
    + solver code needs to be 10 bytes at most.

* Normal solidity contract below will compiles into a much larger bytecode because it Solidity auto inserts additional code/instruction such as
    + function dispatching 
    + abi encoding
    + metadata
    + revert handling

```solidity
contract Solver {
    function whatIsTheMeaningOfLife()
        external
        pure
        returns(uint256)
    {
        return 42;
    }
}
```
- Therefore the generated runtime code will far exceeding 10 opcodes 
- the author note suggest to use assembly by hinting "leaving the comfort of solidity"

### Using low level instructions
The smallest possible runtime logic is basically:
1. Put 42 into memory
2. Return it

#### Runtime Bytecode
| Opcode  | Instruction | Meaning
| ------- | ----------- | --------
| `60 2a` | PUSH1 0x2a  | Push 42 onto stack
| `60 80` | PUSH1 0x80  | Push 80 onto stack
| `52`    | MSTORE      | Store 42 into memory at position 0x80
| `60 20` | PUSH1 0x20  | Push return size of '32' bytes onto the stack
| `60 80` | PUSH1 0x80  | Push the start the position of return data
| `f3`    | RETURN      | Return 32 bytes of memory starting at position 0x80

```
Runtime bytecode: 
= 602a60805260206080f3
```

#### Creation bytecode
1. Put runtime bytecode into memory
2. RETURN runtime bytecode
| Opcode                    | Instruction | Meaning
| ------------------------- | ----------- | --------------------------------
| `69 <runtime_bytecode>`   | PUSH10 runtime_bytecode     | Push 42 onto stack
| `60 00`                   | PUSH1 0x00  | Push 00 onto stack
| `52`                      | MSTORE      | Store `runtime_bytecode` into memory at position 0x00
| `60 0a`                   | PUSH1 0x0a  | Push return size of 10 bytes onto the stack
| `60 16`                   | PUSH1 0x16  | Push 22, the start the position of return data
| `f3`                      | RETURN      | Return 10 bytes of memory starting at position 0x00
```
Creation bytecode:
= 69<runtime_bytecode>600052600a6016f3
= 69602a60805260206080f3600052600a6016f3
```

- Deploy the contract to the chain:
```bash
$ cast send --private-key $PK --rpc-url $RPC_URL \
    --create "0x69602a60805260206080f3600052600a6016f3"

blockHash            0x85d79fe1c0741f80f40072d10e773b1ea1a9477413c8d06b2812ec0c9668e32b
blockNumber          10938512
contractAddress      0x25fA9367C3A9DAE8966896de02d8E98cbF8BcaD9
cumulativeGasUsed    17941800
effectiveGasPrice    15367736218
```

- Verify the deployed contract
```bash
$ cast code 0x25fA9367C3A9DAE8966896de02d8E98cbF8BcaD9 --rpc-url $RPC_URL 
0x602a60805260206080f3
```
- runtime bytecode is returned withtout the creation bytecode

```bash
❯ cast call 0x25fA9367C3A9DAE8966896de02d8E98cbF8BcaD9 --rpc-url $RPC_URL

0x000000000000000000000000000000000000000000000000000000000000002a
```
- 42 with the size of 32 bytes is returned 
- Set the solver address to our address to solve the challenge
```bash
cast send 0x88324850D1332A07264fe07d54ae62818EE76Fdb \
"setSolver(address)" 0x25fA9367C3A9DAE8966896de02d8E98cbF8BcaD9 \
--private-key $PK --rpc-url $RPC_URL
```
