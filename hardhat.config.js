require("@nomicfoundation/hardhat-toolbox");

// hardhat.config.js
// const { mnemonic, bscscanApiKey } = require('./secrets.json');

require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "testnet",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
      },
      hardhat: {
      },
      testnet: {
        url: "https://data-seed-prebsc-1-s1.binance.org:8545",
        chainId: 97,
        gasPrice: 20000000000,
        accounts: ['Your Private-Key',]
      },
      mainnet: {
        url: "https://bsc-dataseed.binance.org/",
        chainId: 56,
        gasPrice: 20000000000,
        accounts: ['Your Private-Key',]
      }
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://bscscan.com/
    apiKey: 'AP KEY'
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true
      }}
   }
};
