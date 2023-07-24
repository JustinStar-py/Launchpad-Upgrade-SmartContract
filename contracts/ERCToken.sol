// SPDX-License-Identifier: MIT-3.0-only
pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Token is ERC20 {
  IERC20 public token;
  uint256 public depositDeadline;
  uint256 public lockDuration;

  constructor() ERC20("Launchpad Token", "PAD") {
        _mint(msg.sender, 1000 * 10 ** 18);
  }
}