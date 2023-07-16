// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

contract CloneFactory {
    address[] public totalAddress;
    address public template;

    constructor(address _template) {
        template = _template;
    }

    function createClone(uint256 arg1, string memory arg2) external returns (address result) {
        address clone = Clones.clone(template);
        totalAddress.push(clone);

        YourContract(clone).initialize(arg1, arg2);

        return clone;
    }
}

contract YourContract {
    uint256 public value;
    string public message;

    constructor() {
    }

    function initialize(uint256 _value, string memory _message) external {
        require(value == 0 && bytes(message).length == 0, "Contract already initialized");

        value = _value;
        message = _message;
    }
}