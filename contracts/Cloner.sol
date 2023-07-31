// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CloneFactory {
    address[] public totalPadsContracts;
    
    struct padInfo {
      // ---------------
      // rate
      // softCap
      // hardCap
      // minBuy
      // maxBuy
      // ---------------
      // token name
      // website
      // telegram
      // twitter
      // information
      // ---------------
      // startTime
      // endTime
      // totalBnbRaised
      // presaleEnded
      uint id;
      address tokenCA;
      address pool;
      uint[5] padConfiguration;
      string[5] padDetails;
      bool whitelistOption;
      uint endTime;
      uint startTime;
      uint256 totalBnbRaised;
      address padOwner;
   }
    
    
   uint256 public feePoolPrice = 0.1 ether;
   address public companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;
   
   padInfo[] public totalPads;
   mapping(address => padInfo[]) public padOwners;

   function createClone(address _targetContract, address _tokenContractAddress, 
            uint256[5] memory _padConfiguration, 
            string[5] memory _padDetails, bool _whitelistOption, 
            uint256 _endTime, uint256 _startTime) external payable returns (address) {
         require(msg.value >= feePoolPrice, "Payment failed! the amount is less than expected.");
         // require(_endTime > block.timestamp, "End-time must be more in future.");
         require(payTo(companyAcc, msg.value));
         require(_endTime > block.timestamp, "End-time of launchpad should be in the future.");

         address clone = Clones.clone(_targetContract);
         initialPad(clone).initialize(
            totalPads.length,
            _tokenContractAddress,
            _padConfiguration,
            _padDetails,
            _whitelistOption,
            _endTime,
            _startTime,
            0,
            msg.sender
      );
        
         totalPads.push(padInfo(
            totalPads.length,
            _tokenContractAddress,
            clone,
            _padConfiguration,
            _padDetails,
            _whitelistOption,
            _endTime,
            _startTime,
            0,
            msg.sender
         ));

         totalPadsContracts.push(clone);
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
   
   function _getOwnerPresalesCount(address requiredOwner) public view returns (uint) {
      uint count = padOwners[requiredOwner].length;
      return count;
   }

   function _returnPresalesCount() public view returns (uint) {
      return totalPads.length;
   }

   function _returnTotalPads() public view returns(padInfo[] memory){
        return totalPads;
   }

}

contract initialPad is Initializable {
    using SafeMath for uint256;
    
    uint256 public id;
    address public tokenContractAddress;
    uint[5] public padConfiguration;
    string[5] public padDetails;
    bool public whitelistOption;
    uint256 public endTime;
    uint256 public startTime;
    uint256 public totalBnbRaised;
    address public padOwner;

    function initialize (
         uint _id,
         address _tokenContractAddress,
         uint256[5] memory _padConfiguration,
         string[5] memory _padDetails,
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

}