const { ethers, upgrades, config } = require("hardhat");

const UPGRADEABLE_PROXY = "0x834aDe89F14B5A724cD4beE5c5B5883c65ae46ba";


async function upgradeContract() {
    const Enterprise = await ethers.getContractFactory("Enterprise");
    let enterpriseProxy = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, Enterprise);
    console.log("V2 Contract Deployed to:", enterpriseProxy.address);
}

async function main() {
    const [owner] = await ethers.getSigners();
    console.log("Deploying the contract with the account:", await owner.getAddress());
    try {
        await upgradeContract();
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
    upgradeContract,
};
