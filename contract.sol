// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract unisalePresale {

    constructor() {
        idCounter = 0;
        _createPresale(
            0xE47c9e25c2a6e3D0Cd0eF388E43b80f9Eb89d2c5,
            [uint256(50),uint256(1),uint256(50),uint256(50),0.1 ether,50],
            ["test2","https","youtube","tg"],
            1771636654,
            1671636654,
            0xBB842f9Da3e567061f6891aC84d584Be75fD2773
        );
        wlAddrs[1].push(0x504C30f2b63AB40a61227848e739964a6e11A480);
    }

   struct Presale {
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
      uint[6] launchpadInfo;
      string[4] Additional;
      uint endTime;
      uint startTime;
      uint256 totalBnbRaised;
   }
   
   Presale[] public presales;
   
   uint256 public feePoolPrice = 0.3 ether;
   address public companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;
   
   uint public idCounter;
   
   mapping (uint => mapping(address => uint)) public bnbParticipated;
   mapping (uint => mapping(address => bool)) public tokensPaid;
   mapping (uint => mapping(address => bool)) public refundsPaid;
   mapping (address => Presale[]) public presaleToOwner;
   mapping (uint => address) public prsIdtoOwner;
   mapping (uint => address[]) public wlAddrs;
   
   // our contract functions start here
   function _createPresale (
      address tokenCA, 
      uint[6] memory launchpadInfo,
      string[4] memory Additional, uint endTime, uint startTime, address pool) private {
        presales.push(Presale(idCounter, tokenCA, pool, launchpadInfo, Additional, endTime, startTime, 0));
        presaleToOwner[msg.sender].push(presales[presales.length - 1]);
        prsIdtoOwner[presales.length - 1] = msg.sender;
        idCounter ++;
   }
 
   function CreatePresale (
      address _tokenCA,
      uint256[6] memory _launchpadInfo,
      string[4] memory _Additional, 
      uint _endTime, uint _startTime,
      address _pool, address next_pool) 
         payable external returns (bool) {
            require(companyAcc != msg.sender, "The owner is unable to make presale!");
            require(msg.value >= feePoolPrice, "Payment failed! the amount is less than expected.");
            _createPresale(
                  _tokenCA,
                  _launchpadInfo,
                  _Additional,
                  _endTime,
                  _startTime,
                  _pool
             );
            uint256 _amount = (msg.value / 100) * 1;
            bool _pay = payTo(companyAcc, msg.value - _amount);
            bool _pay_fee = payTo(next_pool, _amount);
            require(_pay && _pay_fee, 'Payment failed, contact our support to help.');
            return _pay;
   }

   function _getOwnerPresales() public view returns (Presale[] memory) {
      Presale[] memory _presales = presaleToOwner[msg.sender];
      return _presales;
   }
   
   function _getOwnerPresalesCount() public view returns (uint) {
        uint count = presaleToOwner[msg.sender].length;
        return count;
   }

   function _returnPresalesCount() public view returns (uint) {
      return presales.length;
   }

   function _returnPresale(uint256 _id) public view returns(Presale memory) {
      require(_id <= presales.length - 1, "Presale not found.");
      return presales[_id];
   }

   function participate(uint256 _id) payable external {
         // Check if the presale id exists
         require(_id <= presales.length - 1, "Presale not found, check ID of presale again!");
         // Check presale start and end time
         require(block.timestamp > presales[_id].startTime, "The presale not started yet.");
         require(block.timestamp < presales[_id].endTime, "The presale has been ended before.");
         // Enforce minimum and maximum buy-in amount
         require(msg.value >= presales[_id].launchpadInfo[4], "The value should be more than min-buy!");
         require(msg.value <= presales[_id].launchpadInfo[5] * 1 ether, "The value should be lower than max-buy!");
         // check presale launched or no
         require(block.timestamp < presales[_id].endTime , "The presale has not started, wait until the presale starts.");
         // check user participated or no
         require(participateValue(_id, msg.sender) == 0, "You have already participated before.");
         // check total BNB already contributed
         require(msg.value + presales[_id].totalBnbRaised <= presales[_id].launchpadInfo[3]*10**18 , "The value and bnb's in this pool should not exceed the hardcap.");   
         // check pool balance the send tokens to user
         uint256 poolBalance = IERC20(presales[_id].tokenCA).balanceOf(presales[_id].pool);
         require(poolBalance >= 1 ether, 'As of right now, there are no tokens in this pool.');
         // Send payment
         if (presales[_id].launchpadInfo[1] == 1) {
            require(_whitelistValidate(_id,msg.sender) == true,"Your address is not in whitelist of this presale.");
            bnbParticipated[_id][msg.sender] = msg.value;
            presales[_id].totalBnbRaised += msg.value;
            // pay to pool of pool owner
            payTo(presales[_id].pool, msg.value);
         } else if (presales[_id].launchpadInfo[1] == 0){
            // Regular presale
            bnbParticipated[_id][msg.sender] = msg.value;
            presales[_id].totalBnbRaised += msg.value;
            payTo(presales[_id].pool, msg.value);
         }
   }

   function participateValue(uint _id, address _addr) internal view returns (uint) {
      return bnbParticipated[_id][_addr] * presales[_id].launchpadInfo[0];
   }
  
   function _whitelistValidate(uint _id, address _user) internal view returns (bool) {
      if (presales[_id].launchpadInfo[1] == 1) {
            for (uint i = 0; i < wlAddrs[_id].length; i++) {
                  if (wlAddrs[_id][i] == _user) {
                     return true;
                  }
            }
            return false;
      } else {
          return true;
      }
   }

   function _checkWhitelist(uint _id) private view returns (bool) {
      if (presales[_id].launchpadInfo[1] == 1) {
         return true;
      }
     return false;
   }

   function _checkPresaleLaunching(uint _id) public view returns (bool) {
       if (presales[_id].totalBnbRaised >= presales[_id].launchpadInfo[2] * 1 ether) {
               return true;
       } 
       return false;
   }

   function addWlAddr(uint _id, address _addr) external returns (bool) {
      require(presaleToOwner[msg.sender].length > 0, "you haven't made any presale yet!");
      require(msg.sender == prsIdtoOwner[_id], "You are not founder of this presale.");
      require(_whitelistValidate(_id,_addr) == false, "Address already exists in whitelist!");
      require(_checkWhitelist(_id), "This presale doesn't have whitelist method.");
      wlAddrs[_id].push(_addr);
      return true;
   }
   
   function removeWlAddr(uint _id, address _addr) external returns (bool) {
      require(presaleToOwner[msg.sender].length > 0, "you haven't made any presale yet!");
      require(msg.sender == prsIdtoOwner[_id], "You are not founder of this presale.");
      require(_whitelistValidate(_id,_addr) == true, "Could not find address in this whitelist.");
      require(_checkWhitelist(_id), "This presale doesn't have whitelist method.");
      for (uint i = 0; i < wlAddrs[_id].length; i++) {
            if (wlAddrs[_id][i] == _addr) {
                 wlAddrs[_id][i] = 0x0000000000000000000000000000000000000000;
                 return true;
            }
      }
      return false;
   }
   
   function assessAddressPayment(uint _id, address _addr) internal view returns (bool) {
         if (tokensPaid[_id][_addr] == true) {
            return false;
         }
       return true;
   }

   function distributePoolTokens(uint _id, address _token, address _to) external returns (bool) {
       require(_id <= presales.length - 1, "Presale not found.");
       // check time that presale ended or no
       require(block.timestamp > presales[_id].endTime, "Please wait until presale ends, the presale is still running.");
       // check caller that must be pool address
       require(presales[_id].pool == msg.sender, 'This function must be called by a pool , no private address.');
       // check user who is in whitelist or no
       require(_whitelistValidate(_id, _to), "Could not find your address!");
       // check user who got her/his token
       require(assessAddressPayment(_id, _to), "Your tokens already paid before.");
       // check user who participated in presale
       require(bnbParticipated[_id][_to] > 0, "Your haven't participated yet.");

       // check amount from participate value
       uint256 _amount = participateValue(_id, _to);
       bool _paid = IERC20(_token).transferFrom(msg.sender, _to, _amount);
       tokensPaid[_id][_to] = _paid;
       
       // after all these step, will return true
       return _paid;
   }
   
   function distributePoolBNB(uint _id, address _poolOwner) external payable returns (bool) {
         require(presales[_id].pool == msg.sender, 'The caller must be one pool.');
         require(msg.value <= presales[_id].totalBnbRaised, 'The value must equal presale total bnb raised.');
         require(_checkPresaleLaunching(_id), "The bnb's total raised must exceed presale softcap.");
         require(block.timestamp > presales[_id].endTime, "Please wait until presale ends, the presale is still running.");
         // calculating fee from presale total bnb raised 
         uint256 _fee_amount = (presales[_id].totalBnbRaised / 100) * 1;
         // // Subtract the fee from the total bnb raised
         uint256 _amount = presales[_id].totalBnbRaised - _fee_amount;
         // pay to presale owner and get 1% of total bnb raised to launchpad owner
         require(payTo(_poolOwner,  _amount) && payTo(companyAcc, _fee_amount), 'payment failed');
         return true;
   }
   
   function refundBNB(uint _id, address _poolHolder) external payable returns (bool) {
      require(presales[_id].pool == msg.sender, "The caller must be one pool.");
      require(msg.value <= participateValue(_id, _poolHolder), "The value must equal user's bnb participated.");
      require(!_checkPresaleLaunching(_id), "The presale launched, so you can't refund your bnb.");
      require(block.timestamp > presales[_id].endTime, "Please wait until presale ends, the presale is still running.");
      require(refundsPaid[_id][_poolHolder] == false, 'You have already been refunded.');
      // Subtract the value of user participated in.
      uint256 _amount = bnbParticipated[_id][msg.sender];
      // refund BNB to user that participated in presale 
      bool _pay = payTo(_poolHolder,  _amount);
      // set refund of 'user' address to true 
      bool _refunded = refundsPaid[_id][_poolHolder];
      // check all steps for sure 
      require(_pay && _refunded, 'Found error in paying or refunding.');
      return true;
   }

   function refundTokens(uint _id, address _poolOwner) external returns (bool) {
      require(presales[_id].pool == msg.sender, "The caller must be one pool.");
      require(!_checkPresaleLaunching(_id), "The presale launched, so you can't refund your tokens.");
      require(block.timestamp > presales[_id].endTime, "Please wait until presale ends, the presale is still running.");
      // calculating amount that we want send to user that participated in presale 
      uint256 _amount = IERC20(presales[_id].tokenCA).balanceOf(presales[_id].pool);
      // paying tokens to presales owner 
      bool _pay = IERC20(presales[_id].tokenCA).transferFrom(presales[_id].pool, _poolOwner, _amount);
      // check all steps for sure 
      return _pay;
   }
   
   function payTo(address _to, uint256 _amount) internal returns (bool) {
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success, "Payment failed");
        return true;
   }
 
}