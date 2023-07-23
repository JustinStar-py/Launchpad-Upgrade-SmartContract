require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "testnet",
  networks: {
    localhost: {
        url: "http://127.0.0.1:8545",
        accounts: [process.env.LOCALHOST_ACC,]
      },
    hardhat: {
      },
    testnet: {
        url: "https://clean-restless-feather.bsc-testnet.discover.quiknode.pro/395608a8a3773bdc951423350b76ea030cc43cae/",
        // url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
        chainId: 97,
        gasPrice: 12000000000,
        accounts: [process.env.BSC_ACC,]
      },
    bsc_mainnet: {
          url: "https://bsc-dataseed.binance.org/",
          chainId: 56,
          gasPrice: 20000000000,
          accounts: [process.env.BSC_ACC,]
      },
    ethereum: {
        url: "https://www.noderpc.xyz/rpc-mainnet/public",
        chainId: 1,
        accounts: [process.env.BSC_ACC,]
      },
    sepolia: {
        // url: "https://eth-sepolia.g.alchemy.com/v2/demo",
        url: "https://eth-sepolia.public.blastapi.io",
        chainId: 11155111,
        accounts: [process.env.BSC_ACC,]
      }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://bscscan.com/
    apiKey: process.env.BSCSCAN_API
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true
      }}
   }
};