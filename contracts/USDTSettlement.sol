// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract USDTSettlement {
    string public name = "USDT Settlement Token";
    string public symbol = "USDT";
    uint8 public decimals = 6;

    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 initialSupply, address receiver) {
        owner = msg.sender;
        totalSupply = initialSupply;
        balanceOf[receiver] = initialSupply;
        emit Transfer(address(0), receiver, initialSupply);
    }
}
