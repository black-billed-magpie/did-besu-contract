const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("OpenDID Contract", function () {
    this.timeout(50000);

    async function deployContract() {
        const [owner, otherAccount] = await ethers.getSigners();

        const Contract = await ethers.getContractFactory("MultibaseContract");
        const contract = await Contract.deploy();

        return { contract, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Should emit MultibaseContractSetup event on initialization", async function () {
            const { contract } = await loadFixture(deployContract);

            await expect(contract.deploymentTransaction())
                .to.emit(contract, "MultibaseContractSetup")
        });
    })

    describe("Multibase Encoding", function () {
        it("Should encode a string to multibase base58", async function () {
            const { contract } = await loadFixture(deployContract);

            const inputString = "Hello, Multibase!";
            const inputBytes = Buffer.from(inputString, "utf-8");
            const expectedOutput = "zgTazoqFvne8S2mdZd6ZBbje"; // Example expected output

            const result = await contract.encodeMultibase(inputBytes, "base58");
            expect(result).to.equal(expectedOutput);
        });

        it("Should encode a string to multibase base64", async function () {
            const { contract } = await loadFixture(deployContract);

            const inputString = "Hello, Multibase!";
            const inputBytes = Buffer.from(inputString, "utf-8");
            const expectedOutput = "mSGVsbG8sIE11bHRpYmFzZSE="; // Example expected output

            const result = await contract.encodeMultibase(inputBytes, "base64");
            expect(result).to.equal(expectedOutput);
        });

    });

    describe("Multibase Decoding", function () {
        it("Should decode a multibase base58 string", async function () {
            const { contract } = await loadFixture(deployContract);

            const inputString = "zgTazoqFvne8S2mdZd6ZBbje";
            const expectedOutput = "Hello, Multibase!";

            const result = await contract.decodeMultibase(inputString);
            console.log("Decoded hex:", result);
            const resultString = Buffer.from(result.slice(2), "hex").toString("utf-8").replace(/\u0000/g, "");
            console.log("Decoded string:", resultString);
            expect(resultString).to.equal(expectedOutput);
        });

        it("Should decode a multibase base64 string", async function () {
            const { contract } = await loadFixture(deployContract);

            const inputString = "mSGVsbG8sIE11bHRpYmFzZSE=";
            const expectedOutput = "Hello, Multibase!";

            const result = await contract.decodeMultibase(inputString);
            const resultString = Buffer.from(result.slice(2), "hex").toString("utf-8");
            expect(resultString).to.equal(expectedOutput);
        });
    });
});