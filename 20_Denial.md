# Challenge 20 Denial
## Author Note
* This is a simple wallet that drips funds over time. You can withdraw the funds slowly by becoming a withdrawing partner.

* If you can deny the owner from withdrawing funds when they call withdraw() (whilst the contract still has funds, and the transaction is of 1M gas or less) you will win this level.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```
## Solution
1. The core vulnerability is the low level `call` inside the `withdraw()` function that did not set any gas limit which allow DoS. 

2. a mallicious attacker contract can be registered as the `partner` of the vulnerable contract and drain all the gas during the transaction with infinite loop/revert.

3. [Mallicious Contract](src/20_Denial.sol)

4. Two ways to cause gas exhaustion via malliciuos `receive()` function:
    * unbounded Loop atk
    * Cascading Reentrancy 

4. There are multiple ways to perform exhaust the gas limit. here are few.
    - Loop manipulation - iterate over unbounded ds
    - excessive external call complexity
    - Deep call stack exploitation. Eth call stack depth limit is 1024
    - Revert Bombing. force revert while deep in nesting calls

## Execution
```sh
## Deploy Contract
forge create src/20_Denial.sol:Denial --rpc-url $RPC_URL --private-key $PK --broadcast

## Register the mallicious contract as `partner`
cast send $INSTANCE "setWithdrawPartner(address)" $MALLICIOUS_ADDR --rpc-url $RPC_URL --private-key $PK 
```

## Key Takeaways
To protect smart contracts against this in production, we can
* *Set Gas Limits:*
    - When calling external addresses, explicitly specify the gas to prevent a malicious contract from draining transaction's gas pool 
    ```solidity
    partner.call{value:amountToSend, gas: 50000}(""))
    ```
* *Checks-Effects-Interactions:*
    - Follow the standard pattern of handling all state changes before calling external contracts.
* *Pull over Push:*
    - Avoid automatic Ether transfers; instead, use the withdrawal pattern where users claim their own funds.
