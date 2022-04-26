/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const dotenv = require("dotenv");
dotenv.config();
dotenv.config({ path: `.env.${process.env.NODE_ENV}`, ovveride: true });

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
// require("hardhat-gas-reporter");

module.exports = {
  paths: {
    sources: "./{contracts,test/fixtures}",
  },
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
        details: {
          yul: false,
        },
      },
    },
  },
  networks: {
    mainnet: {
      url: process.env.MAINNET_ENDPOINT,
      accounts: [process.env.PRIVATE_KEY],
    },
    rinkeby: {
      url: process.env.RINKEBY_ENDPOINT,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: !!process.env.REPORT_GAS,
  },
};
