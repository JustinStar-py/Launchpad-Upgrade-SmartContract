// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CloneFactory {
    address[] public contractsArray;
    
    struct padInfo {
      // rate
      // method
      // softCap
      // hardCap
      // minBuy
      // maxBuy
      // info
      // tgLink
      // ybLink
      // twLink
      // startTime
      // endTime
      // totalBnbRaised
      // presaleEnded
      uint id;
      address tokenCA;
      address pool;
      uint[6] padConfiguration;
      string[4] padDetails;
      uint endTime;
      uint startTime;
      uint256 totalBnbRaised;
   }
    
    
   uint256 public feePoolPrice = 0.1 ether;
   address public companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;
   
   padInfo[] public totalPads;
   mapping(address => padInfo[]) public padOwners;

   function createClone(
      address _contractTarget,
      address _tokenContractAddress,
      uint256[6] memory _padConfiguration,
      string[3] memory _padDetails,
      bool _whitelistOption,
      uint256 _endTime,
      uint256 _startTime
    ) external payable returns (address) {
         require(msg.value >= feePoolPrice, "Payment failed! the amount is less than expected.");
         require(payTo(companyAcc, msg.value));

        address clone = Clones.clone(_contractTarget);
        Pad(clone).initialize(
            _tokenContractAddress,
            totalPads.length,
            _padConfiguration,
            _padDetails,
            _whitelistOption,
            _endTime,
            _startTime,
            0,
            msg.sender
       );
        
        contractsArray.push(clone);
        return clone;
    }

   function payTo(address _to, uint256 _amount) internal returns (bool) {
       (bool success,) = payable(_to).call{value: _amount}("");
       require(success, "Payment failed");
       return true;
   }

   function _getOwnerPresales() public view returns (padInfo[] memory) {
      padInfo[] memory _padOwners = padOwners[msg.sender];
      return _padOwners;
   }
   
   function _getOwnerPresalesCount() public view returns (uint) {
      uint count = padOwners[msg.sender].length;
      return count;
   }

   function _returnPresalesCount() public view returns (uint) {
      return totalPads.length;
   }

   function _returnPresaleStatus(uint _id) public view returns (string memory) {
      uint endTime = totalPads[_id].endTime;
      uint currentTime = block.timestamp;
      // check the time of presale
      if (currentTime > endTime) {
          // check presale launching
          if (totalPads[_id].totalBnbRaised >= totalPads[_id].padConfiguration[2]) {
             return "ended";
          } else {
            return "canceled";
          }
      } else {
         return "active";
      }
   }
}

contract Pad is Initializable {
    using SafeMath for uint256;
    
    address public tokenContractAddress;
    uint256 public id;
    uint[6] padConfiguration;
    string[3] padDetails;
    bool whitelistOption;
    uint256 public endTime;
    uint256 public startTime;
    uint256 public totalBnbRaised;
    address public padOwner;

    function initialize (
         address _tokenContractAddress,
         uint _id,
         uint256[6] memory _padConfiguration,
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
    }

    mapping (address => bool) public tokenRecipients;
    mapping (address => bool) public whitelistMembership;
    mapping (address => uint256) public usersContributions;

    modifier whitelistChecker() {
         require(whitelistOption, "The presale doesn't have whitelist method");
         _;
   }

   // check payment of tokens for paying tokens to user
   modifier assessAddressPayment(address _addr) {
      require (!tokenRecipients[_addr], "The user has already received their token allocation.");
      _;
   }

    function whitelistValidate(address _user) internal view returns (bool) {
       return whitelistMembership[_user];
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
            require(whitelistValidate(msg.sender) == true,"Your address is not in whitelist of address(this) presale.");
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

    function participateValue(address _addr) internal view returns (uint) {
      return usersContributions[_addr] * padConfiguration[0];
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
         require(whitelistValidate(_recipient), "Address is not whitelisted.");
         require(usersContributions[_recipient] > 0, "Address did not participate in the presale.");
      
         // // check presale status 
         // require(keccak256(bytes(_returnPresaleStatus(_id))) == keccak256(bytes("ended")), "The bnb's total raised must exceed presale softcap.");
         
         // Transfer tokens from the pool to the recipient
         uint256 amount = participateValue(_recipient);
         require(IERC20(tokenContractAddress).transferFrom(address(this), _recipient, amount), "Failed to transfer tokens.");

         // Update tokensPaid mapping
         // tokensPaid[_id][_recipient] = true;

         return true;
   }

   function payTo(address _to, uint256 _amount) internal returns (bool) {
      (bool success,) = payable(_to).call{value: _amount}("");
      require(success, "Payment failed");
      return true;
   }
}