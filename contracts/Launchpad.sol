// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

contract CloneFactory {
    address[] public contractsArray;

    function createClone(uint256 number, address target) external returns (address) {
        address clone = Clones.clone(target);
        SimpleContract(clone).initialize(number);

        contractsArray.push(clone);

        return clone;
    }
}

contract SimpleContract is Initializable {
    uint public value;

    function initialize(uint256 number) external {
        value = number;
    }

    function setValue(uint newValue) external {
        value = newValue;
    }

    function getValue() external view returns (uint) {
        return value;
    }
}