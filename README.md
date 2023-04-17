# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

# PresaleSolidityContract
<h3>PresaleSolidityContract<h3>
<h4>Wrritten by Solidity 8.17V </h5>
# Sample Hardhat Project

<h5>This contract whats includes?<p>


<li> Time Locker </p>
<li> BNB Locker </p>
<li> LIQ Locker </p>
<li> Token Paying </p>
<li> BNB Paying </p>
<li> Whitelist Method </p>
<li> Private Sell </p>
<li> Public Sell </p>



<h2> _________________________________ </h2>


<h4> Using this function for creating new presale</h4>


<pre>
function CreatePresale ( 
     address _tokenCA,uint256[6] memory _launchpadInfo, 
     string[4] memory _Additional,  
     uint _endTime, 
     uint _startTime, 
     address _pool, 
     address next_pool
   ) {<a href='https://github.com/JustinStar-py/Private-Sell-Solidity-Contract/blob/main/contract.sol#L94'>...</a>}
 </pre>
 <p> Line 94 </p>



 <h4> Using this function for participate in presale</h4>

 <pre>
 function participate(uint256 _id)
      payable external {<a href='https://github.com/JustinStar-py/Private-Sell-Solidity-Contract/blob/main/contract.sol#L153'>...}
 </pre>
<p> Line 153 </p>



<h4> Using this function for get tokens</h4>

<pre>
   function distributePoolTokens(
     uint _id, 
     address _recipient
  )
      external assessAddressPayment(_id, _recipient) returns (bool) {<a href='https://github.com/JustinStar-py/Private-Sell-Solidity-Contract/blob/main/contract.sol#L208'>...</a>}
</pre>
<p> Line 208 </p>



<h4> Using this function for paying bnb to owner of presale</h4>
<pre>
 function distributePoolBNB(
    uint _id,
    address _poolOwner
  ) external payable returns (bool) {<a href='https://github.com/JustinStar-py/Private-Sell-Solidity-Contract/blob/main/contract.sol#L237'>...</a>}
</pre>
<p> Line 237 </p>