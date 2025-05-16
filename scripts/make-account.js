// import Web3 from 'web3';

// const host = 'http://10.48.17.210:8545';
// const web3 = new Web3(host);
// // Pre-seeded account with 90000 ETH
// const privateKeyA =
//     "0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3";
// const accountA = web3.eth.accounts.privateKeyToAccount(privateKeyA);
// var accountABalance = web3.utils.fromWei(
//     await web3.eth.getBalance(accountA.address),
// );
// console.log("Account A has balance of: " + accountABalance);

// // Create a new account to transfer ETH to
// var accountB = web3.eth.accounts.create();
// var accountBBalance = web3.utils.fromWei(
//     await web3.eth.getBalance(accountB.address),
// );
// console.log("Account B has balance of: " + accountBBalance);

const fs = require('fs');
const forge = require('node-forge');
const { Wallet } = require('ethers');

const pem = fs.readFileSync('./scripts/eth_private_key_pkcs8.pem', 'utf8');
const base64 = pem
  .replace(/-----(BEGIN|END) (EC|PRIVATE) KEY-----/g, '')
  .replace(/\s+/g, '');
const der = Buffer.from(base64, 'base64');

// const privateKeyObj = forge.pki.privateKeyFromPem(pem);

// const privateBigInt = privateKeyObj.d;
const privatekeyHex = der.slice(-32).toString('hex');

const wallet = new Wallet('0x' + privatekeyHex);
console.log('Address: ' + wallet.address);
console.log('Private Key: ' + wallet.privateKey);