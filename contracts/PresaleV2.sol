// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

contract unisalePresale is Initializable {
    using SafeMath for uint256;
   
    address public tokenContractAddress;
    uint256 public id;
    uint[6] padConfiguration;
    string[3] padDetails;
    bool whitelistOption;
    uint256 public endTime;
    uint256 public startTime;
    uint256 public totalBnbRaised;
    
    function initialize (
         address _tokenContractAddress,
         uint _id,
         uint256[6] memory _padConfiguration,
         string[3] memory _padDetails,
         bool _whitelistOption,
         uint256 _endTime,
         uint256 _startTime,
         uint256 _totalBnbRaised
      ) external {
           tokenContractAddress = _tokenContractAddress;
           id = _id;
           padConfiguration = _padConfiguration;
           padDetails = _padDetails;
           whitelistOption = _whitelistOption;
           endTime = _endTime;
           startTime = _startTime;
           totalBnbRaised = _totalBnbRaised;
    }

    mapping (address => bool) public tokenRecipients;
    mapping (address => bool) public whitelistValidity;
    mapping (address => uint256) public usersContributions;

    modifier _whitelistChecker() {
         require(whitelistOption, "The presale doesn't have whitelist method");
         _;
   }

   // check payment of tokens for paying tokens to user
   modifier assessAddressPayment(address _addr) {
      require (!tokenRecipients[_addr], "The user has already received their token allocation.");
      _;
   }

    function _whitelistValidate(address _user) internal view returns (bool) {
       return whitelistValidity[_user];
   }

    function participate() payable external {
         // Check presale start and end time
         require(block.timestamp > startTime, "The presale not started yet.");
         require(block.timestamp < endTime, "The presale has been ended before.");
         // Enforce minimum and maximum buy-in amount
         require(msg.value >= padConfiguration[4], "The value should be more than min-buy!");
         require(msg.value <= padConfiguration[5] * 1 ether, "The value should be lower than max-buy!");
         // check presale launched or no
         require(block.timestamp < endTime , "The presale has not started, wait until the presale starts.");
         // check user participated or no
         require(usersContributions[msg.sender] == 0, "You have already participated before.");
         // check total BNB already contributed
         // require(msg.value + totalBnbRaised <= padConfiguration[3] * 1 ether , "The value of bnb's in pool should not exceed the hardcap.");   
         // check pool balance the send tokens to user
         uint256 poolBalance = IERC20(tokenContractAddress).balanceOf(address(this));
         require(poolBalance >= 1 ether, 'As of right now, there are no tokens in pool.');
         // Send payment
         if (whitelistOption) {
            require(_whitelistValidate(msg.sender) == true,"Your address is not in whitelist of address(this) presale.");
            usersContributions[msg.sender] = msg.value;
            totalBnbRaised += msg.value;
            // pay to pool of pool owner
            payTo(address(this), msg.value);
         } else {
            usersContributions[msg.sender] = msg.value;
            totalBnbRaised += msg.value;
            payTo(address(this), msg.value);
         }
   }
    
   function payTo(address _to, uint256 _amount) internal returns (bool) {
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success, "Payment failed");
        return true;
   }
}