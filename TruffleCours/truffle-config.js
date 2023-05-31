
// const { MNEMONIC, PROJECT_ID } = process.env;

const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();
// console.log('.env.' + process.env.MNEMONIC);

module.exports = {
  networks: {
   development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    
    goerli: {
      provider: () => new HDWalletProvider({
        mnemonic: {
          phrase: process.env.MNEMONIC,
        },
        providerOrUrl: "https://goerli.infura.io/v3/" + process.env.INFURA_ID,
      }),
      network_id: 5,
    },

    mumbai: {
      provider: () => new HDWalletProvider({
        mnemonic: {
          phrase: process.env.MNEMONIC,
        },
        providerOrUrl: "https://polygon-mumbai.g.alchemy.com/v2/" + process.env.MUMBAI_ID,
      }),
      network_id: 80001,
    },
  },
  mocha: {
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.17",
      settings: {          
        optimizer: {  
          enabled: false,
          runs: 200
        }
      }
    }   
 },
 quiet: false
}
