require('@nomiclabs/hardhat-waffle');
require('dotenv').config();
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-etherscan');

const VRF_ADDRESS = "0x046550482B6bfDBfF8d129b81e2A36585ce68735";

module.exports = {
  solidity: "0.8.17",
  defaultNetwork: 'mumbai',
  networks: {
    mumbai: {
      chainId: 80001,
      url: `${process.env.ALCHEMY_MUMBAI_URL}`,
      accounts: [`0x${process.env.MUMBAI_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY,
  },
  // Global Variable
  VRF_ADDRESS
};

