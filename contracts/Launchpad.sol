// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

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
      address contractTarget,
      address tokenCA, 
      uint[6] memory padConfiguration,
      string[4] memory  padDetails,
       uint endTime, 
       uint startTime
    ) external payable returns (address) {
       require(payTo(companyAcc, msg.value));
        
        address clone = Clones.clone(contractTarget);
    //     SimpleContract(clone).initialize(
    //         tokenCA,
    //         launchpadInfo,
    //         Additional,
    //         endTime,
    //         startTime
    //    );
        
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