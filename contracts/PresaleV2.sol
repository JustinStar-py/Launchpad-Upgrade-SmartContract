// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

contract Pad is Initializable {
    using SafeMath for uint256;
    
    uint256 public id;
    address public tokenContractAddress;
    uint[5] public padConfiguration;
    string[3] public padDetails;
    bool public whitelistOption;
    uint256 public endTime;
    uint256 public startTime;
    uint256 public totalBnbRaised;
    address public padOwner;
    
    address public companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;

    function initialize (
         uint _id,
         address _tokenContractAddress,
         uint256[5] memory _padConfiguration,
         string[3] memory _padDetails,
         bool _whitelistOption,
         uint256 _endTime,
         uint256 _startTime,
         uint256 _totalBnbRaised,
         address _padOwner
      ) external {
           tokenContractAddress = _tokenContractAddress;
           id = _id;
           padConfiguration = _padConfiguration;
           padDetails = _padDetails;
           whitelistOption = _whitelistOption;
           endTime = _endTime;
           startTime = _startTime;
           totalBnbRaised = _totalBnbRaised;
           padOwner = _padOwner;

         //   set launchpad platform owner account
           companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;
    }
   
    mapping (address => bool) public tokenRecipientsUsers;
    mapping (address => bool) public whitelistMembership;
    mapping (address => uint256) public usersContributions;

   modifier whitelistChecker() {
         require(whitelistOption, "The presale doesn't have whitelist method");
         _;
   }

   // check payment of tokens for paying tokens to user
   modifier assessAddressPayment(address _addr) {
      require (!tokenRecipientsUsers[_addr], "The user has already received their token allocation.");
      _;
   }
   
    function padStringStatus() public view returns (string memory) {
      uint currentTime = block.timestamp;
      // check the time of presale
      if (currentTime > endTime) {
          // check presale launching
          if (totalBnbRaised >= padConfiguration[2]) {
             return "ended";
          } else {
            return "canceled";
          }
      } else {
         return "active";
      }
   }

    function whitelistValidate(address _user) internal view returns (bool) {
       return whitelistMembership[_user];
   }

    function participateValue(address _addr) internal view returns (uint) {
      return usersContributions[_addr] * padConfiguration[0];
   }

    function participate() payable external {
       // Check presale start and end time
       require(block.timestamp > startTime, "The presale not started yet.");
       require(block.timestamp < endTime, "The presale has been ended before.");
       // Enforce minimum and maximum buy-in amount
       require(msg.value >= padConfiguration[3], "The value should be more than min-buy!");
       require(msg.value <= padConfiguration[4] * 1 ether, "The value should be lower than max-buy!");
       // check presale launched or no
       require(block.timestamp > startTime , "The presale has not started, wait until the presale starts.");
       // check user participated or no
       require(usersContributions[msg.sender] == 0, "You have already participated before.");
       // check total BNB already contributed
       // require(msg.value + totalBnbRaised <= padConfiguration[3] * 1 ether , "The value of bnb's in pool should not exceed the hardcap.");   
       // check pool balance the send tokens to user
      //  uint256 poolBalance = IERC20(tokenContractAddress).balanceOf(address(this));
      //  require(poolBalance >= 1 ether, 'As of right now, there are no tokens in pool.');
       // Send payment
       if (whitelistOption) {
          require(whitelistValidate(msg.sender) == true,"Your address is not in whitelist of address(this) presale.");
          usersContributions[msg.sender] = msg.value;
          totalBnbRaised += msg.value;
          // pay to pool of pool owner
       } else {
          usersContributions[msg.sender] = msg.value;
          totalBnbRaised += msg.value;
       }
   }
   
    function addWlAddr(address _addr) external whitelistChecker {
      require(msg.sender == padOwner, "You are not founder of this presale.");
      require(!whitelistValidate(_addr), "Address already exists in whitelist!");
      whitelistMembership[_addr] = true;
   }
   
    function removeWlAddr(address _addr) external whitelistChecker {
      require(msg.sender == padOwner, "You are not founder of this presale.");
      require(whitelistValidate(_addr), "Could not find address in this whitelist.");
      whitelistMembership[_addr] = false;
   }

    function distributePoolTokens(address _recipient)
      external assessAddressPayment(_recipient) returns (bool) {

         // check that the presale has ended
         require(block.timestamp >= endTime, "Presale is still running.");
         
         // check that the recipient is whitelisted and has participated in the presale
         if (whitelistOption) {
            require(whitelistValidate(_recipient), "Address is not whitelisted.");
         }

         require(usersContributions[_recipient] > 0, "Address did not participate in the presale.");
      
         // check presale status 
         require(keccak256(bytes(padStringStatus())) == keccak256(bytes("ended")), "The bnb's total raised must exceed presale softcap.");
         
         // Transfer tokens from the pool to the recipient
         uint256 amount = participateValue(_recipient);
         require(IERC20(tokenContractAddress).transferFrom(address(this), _recipient, amount), "Failed to transfer tokens.");

         // Update tokensPaid mapping
         tokenRecipientsUsers[_recipient] = true;

         return true;
   }

    function distributePoolBNB(address _recipient) external payable returns (bool) {
        require(msg.sender == padOwner, "Caller should be owner of this pad.");
        require(msg.value <= totalBnbRaised, "The value must equal presale total bnb raised.");
        
         // to check presale status of pool
        require(keccak256(bytes(padStringStatus())) == keccak256(bytes("ended")), "The bnb's total raised must exceed presale softcap.");
        require(block.timestamp > endTime, "Please wait until presale ends, the presale is still running.");
        
        // calculating fee from presale total bnb raised 
        uint256 _fee_amount = (totalBnbRaised / 100) * 1;
        
        // // Subtract the fee from the total bnb raised
        uint256 _amount = totalBnbRaised - _fee_amount;
        
        // pay to pad owner and get 1% of total bnb raised to launchpad platform owner
        require(payTo(_recipient,  _amount) && payTo(companyAcc, _fee_amount), "payment failed");
        return true;
   }

    function emergencyDistributeBNB(address _recipient) external {
        require(address(this).balance > 0, "Insufficient contract balance");
        (bool success, ) = _recipient.call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
   }

    function payTo(address _to, uint256 _amount) internal returns (bool) {
      (bool success,) = payable(_to).call{value: _amount}("");
      require(success, "Payment failed");
      return true;
   }
}