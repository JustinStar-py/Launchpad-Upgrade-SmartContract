// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SimpleContract2 {
    uint public value;

    event ValueUpdated(uint newValue);

    constructor(uint256 number) {
        value = number;
    }

    function setValue(uint newValue) external {
        value = newValue;
        emit ValueUpdated(newValue);
    }

    function getValue() external view returns (uint) {
        return value;
    }
}