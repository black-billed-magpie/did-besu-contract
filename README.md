# DID Besu Contract

**did-besu-contract** is a project implementing the OpenDID EVM Contract, providing functionality to store and manage DID Documents and Verifiable Credential Metadata on the blockchain.
This project is designed to support Decentralized Identifiers (DID) and **Verifiable Credentials (VC)**.

## Software Specifications

- **Smart Contract**: solidity 0.8.27 <=
- **Development Environment**: Hardhat 2.22.19 <=, NodeJs 22.12.0 <=
- **Blockchain Network**: Ethereum-based network

---

## Main Features

- **DID Document Management**: Store, query, update, and change the status of DID documents on the blockchain.
- **VC Metadata Management**: Store and manage metadata for Verifiable Credentials.
- **ZKP Data Management**: Store and query ZKP-related data on the blockchain.
- **Extensibility**: Supports upgradeable smart contracts using the OpenZeppelin library.
- **Access Control**: Supports access control using the OpenZeppelin library.

---

## Installation & Deployment

> You can easily set up an EVM environment using the test network provided by Besu.
> For network setup and contract deployment, refer to [Hyperledger Besu - start node](https://besu.hyperledger.org/private-networks/get-started/start-node) and [Hardhat - deploying to a live network](https://hardhat.org/tutorial/deploying-to-a-live-network).

### 1. Install Dependencies

```bash
npm install
```

### 2. Compile

To compile the smart contracts, run:

```bash
npx hardhat compile
```

### 3. Deploy

To deploy the smart contracts, run:

```bash
npx hardhat run scripts/deploy.js --network <network-name>
```

#### Example Deployment Script

```javascript
const DocumentStorage = await ethers.getContractFactory("DocumentStorage");
const documentStorage = await DocumentStorage.deploy();
const documentStorageAddress = await documentStorage.getAddress();

const VcMetaStorage = await ethers.getContractFactory("VcMetaStorage");
const vcMetaStorage = await VcMetaStorage.deploy();
const vcMetaStorageAddress = await vcMetaStorage.getAddress();

const OpenDID = await ethers.getContractFactory("OpenDID");

const openDIDProxy = await upgrades.deployProxy(OpenDID, [
    documentStorageAddress,
    vcMetaStorageAddress,
], {
    kind: "uups",
});

await openDIDProxy.waitForDeployment();
```

---

### 4. Test

To run tests, use:

```bash
npx hardhat test
```

Example output:

```bash
  VcMetaStorage
    Deployment
    ✔ Should emit DocumentStorageSetup event on initialization
    VcMetaStorage
      ✔ Should store a vcmeta
      ✔ should update a vcmeta status
    VcSchemaMetaStorage
      ✔ Should register a vc schema meta

  ZKPStorage
    Deployment
      ✔ Should emit DocumentStorageSetup event on initialization
    ZKPStorage
      ✔ Should store a schemas
Stored schema value:  Result(5) [ '', '', '', Result(0) [], '' ]
      ✔ Should remove a schema
      ✔ Should store a credential deifinition
      ✔ Should remove a credential definition
```

---

### Reference Links
For more information, refer to the following links:

- [hardhat](https://hardhat.org)
- [solidity 0.8.27](https://docs.soliditylang.org/en/v0.8.27/)
- [Besu](https://besu.hyperledger.org)

---

## Usage Example

The OpenDID Solidity Contract is written using the `Hardhat` framework.
You can check the available methods by reviewing the `OpenDID.sol` file.

Below is an example of calling the contract using `curl`:

### Contract Call Example

```bash
curl -X POST \
--data '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0x69498dd54bd25aa0c886cf1f8b8ae0856d55ff13","value":"0x1"}, "latest"],"id":53}' \ 
http://127.0.0.1:8545/ \
-H "Content-Type: application/json"
```

### Example Output

```json
{
  "jsonrpc": "2.0",
  "id": 1337,
  "result": "0x"
}
```

---

## Directory Structure

```plaintext
did-besu-contract
├── contracts/          # Smart contract code
    ├── data/           # Data contract libraries
    ├── storage/        # Storage contract code
    └── utils/          # Utility contract libraries
├── test/               # Test code
├── scripts/            # Deployment scripts
├── artifacts/          # Compiled artifacts
├── cache/              # Hardhat cache
├── data/               # Sample data and schemas
└── doc/                # Documentation
```

Description of each folder and file:

| Name                   | Description                              |
| ---------------------- | ---------------------------------------- |
| docs                   | Documentation                            |
| contracts              | Smart contract folder                     |
| data                   | Data library storage path                 |
| storage                | Storage contract storage path             |
| utils                  | Utility library storage path              |
| hardhat.config.js      | Hardhat project configuration             |
| scripts                | Project-related scripts                   |

---

### Other Directory Descriptions

| Name                    | Description                              |
| ----------------------- | ---------------------------------------- |
| CHANGELOG.md            | Version history of the project           |
| CODE_OF_CONDUCT.md      | Contributor code of conduct              |
| CONTRIBUTING.md         | Contribution guidelines and procedures   |
| LICENSE                 | License                                  |
| dependencies-license.md | Licenses of project dependencies         |
| MAINTAINERS.md          | Project maintainer guidelines            |
| RELEASE-PROCESS.md      | New version release process              |
| SECURITY.md             | Security policy and vulnerability report |
