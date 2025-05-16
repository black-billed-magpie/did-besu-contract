const { ethers, upgrades, config } = require("hardhat");

async function deployContract() {
    try {
        const DocumentStorage = await ethers.getContractFactory(
            "DocumentStorage",
        );
        const documentStorage = await DocumentStorage.deploy();
        const documentStorageAddress = await documentStorage.getAddress();
        console.log("DocumentStorage deployed to:", documentStorageAddress);

        const VcMetaStorage = await ethers.getContractFactory(
            "VcMetaStorage",
        );
        const vcMetaStorage = await VcMetaStorage.deploy();
        const vcMetaStorageAddress = await vcMetaStorage.getAddress();
        console.log("VcMetaStorage deployed to:", vcMetaStorageAddress);

        const ZKPStorage = await ethers.getContractFactory(
            "ZKPStorage",
        );
        const zkpStorage = await ZKPStorage.deploy();
        const zkpStorageAddress = await zkpStorage.getAddress();
        console.log("ZKPStorage deployed to:", zkpStorageAddress);

        const OpenDID = await ethers.getContractFactory(
            "OpenDID",
        );

        const openDIDProxy = await upgrades.deployProxy(OpenDID, [
            documentStorageAddress,
            vcMetaStorageAddress,
            zkpStorageAddress,
        ], {
            kind: "uups",
        });

        await openDIDProxy.waitForDeployment();

        const contractAddress = await openDIDProxy.getAddress();
        console.log("OpenDID deployed to:", contractAddress);

        const implementationAddress =
            await upgrades.erc1967.getImplementationAddress(contractAddress);
        console.log("Implementation address:", implementationAddress);

        return { proxy: contractAddress, implementation: implementationAddress };
    } catch (error) {
        console.error("Deployment failed:", error);
        throw error;
    }
}

async function main() {
    const [owner] = await ethers.getSigners();
    console.log("Deploying the contract with the account:", await owner.getAddress());
    try {
        await deployContract();
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
}

main().then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

module.exports = {
    deployContract,
};
