/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const dotenv = require("dotenv");
dotenv.config();
dotenv.config({ path: `.env.${process.env.NODE_ENV}`, overide: true });

const networks = process.env.CI
  ? { hardhat: {} }
  : {
      mainnet: {
        url: process.env.MAINNET_ENDPOINT,
        accounts: [process.env.PRIVATE_KEY],
      },
      rinkeby: {
        url: process.env.RINKEBY_ENDPOINT,
        accounts: [process.env.PRIVATE_KEY],
      },
    };

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

if (process.env.REPORT_GAS) {
  require("hardhat-gas-reporter");
}

module.exports = {
  paths: {
    sources: "./{contracts,test/fixtures}",
  },
  solidity: {
    version: "0.8.13",
    settings: {
      // optimizer: {
      //   enabled: false,
      //   runs: 200,
      //   details: {
      //     yul: false,
      //   },
      // },
    },
  },
  networks,
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: !!process.env.REPORT_GAS,
  },
};
