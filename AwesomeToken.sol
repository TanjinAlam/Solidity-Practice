// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract AwesomeToken is ERC20 {
    // uint256 initialSupply = 10000000;

    constructor ()  ERC20 ("XFSV", "BDX"){
        _mint(msg.sender,200000000 ether);
    }
}
