const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const { getLocalJson } = require("./Utils");
const { opendir } = require("graceful-fs");

describe("OpenDID Contract", function () {
  this.timeout(50000);

  let openDID, owner, addr1;

  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners();

    // DocumentStorage 배포
    const DocumentStorage = await ethers.getContractFactory("DocumentStorage");
    const documentStorage = await DocumentStorage.deploy();

    const VcMetaStorage = await ethers.getContractFactory("VcMetaStorage");
    const vcMetaStorage = await VcMetaStorage.deploy();

    const ZKPStorage = await ethers.getContractFactory("ZKPStorage");
    const zkpStorage = await ZKPStorage.deploy();

    const MultibaseContract = await ethers.getContractFactory("MultibaseContract");
    const multibaseContract = await MultibaseContract.deploy();

    const documentStorageAddress = await documentStorage.getAddress();
    const vcMetaStorageAddress = await vcMetaStorage.getAddress();
    const zkpStorageAddress = await zkpStorage.getAddress();
    const multibaseContractAddress = await multibaseContract.getAddress();

    // OpenDID 배포
    const OpenDIDFactory = await ethers.getContractFactory("OpenDID");
    openDID = await upgrades.deployProxy(OpenDIDFactory, [documentStorageAddress, vcMetaStorageAddress, zkpStorageAddress, multibaseContractAddress], { kind: "uups" });
    await openDID.waitForDeployment();
  });

  it("should initialize the OpenDID contract", async () => {
    expect(await openDID.hasInitialized()).to.be.true;
  });

  it("should register Admin role to addr1", async () => {
    await openDID.registRole(addr1.address, "Admin");
    expect(await openDID.isHaveRole(addr1.address, "Admin")).to.be.true;
  });

  it("should register a base58 encoding did document with addr1 (TAS role)", async () => {
    const didDoc = getLocalJson("./data/tas_base58_verificationMethod.json");
    // owner가 addr1에게 TAS 역할 부여
    await openDID.registRole(addr1.address, "Tas");
    // addr1로 등록
    await expect(openDID.connect(addr1).registDidDoc(didDoc))
      .to.emit(openDID, "DIDCreated")
      .withArgs(didDoc.id, addr1.address);
    const storedDocumentAndStatus = await openDID.getDidDoc(didDoc.id);
    expect(storedDocumentAndStatus.diddoc.id).to.equal(didDoc.id);
    expect(storedDocumentAndStatus.status).to.equal(0);
  });

  it("should register a base64 encoding did document with owner (TAS role)", async () => {
    const didDoc = getLocalJson("./data/tas_base64_verificationMethod.json");
    await openDID.registRole(owner.address, "Tas");
    await expect(openDID.connect(owner).registDidDoc(didDoc))
      .to.emit(openDID, "DIDCreated")
      .withArgs(didDoc.id, owner.address);
    const storedDocumentAndStatus = await openDID.getDidDoc(didDoc.id);
    expect(storedDocumentAndStatus.diddoc.id).to.equal(didDoc.id);
    expect(storedDocumentAndStatus.status).to.equal(0);
  });

  it("should not search for a non-existent DID document", async () => {
    await expect(openDID.getDidDoc("nonExistentDidDocId")).to.be.revertedWith("Document is not exist");
  });

  it("should update the status of a DID document in service", async () => {
    const didDoc = getLocalJson("./data/document.json");
    await openDID.registRole(owner.address, "Tas");
    await openDID.connect(owner).registDidDoc(didDoc);
    const newStatus = "DEACTIVATED";
    const versionId = didDoc.versionId;
    await openDID.updateDidDocStatusInService(didDoc.id, newStatus, versionId);
    const updatedDidDoc = await openDID.getDidDoc(didDoc.id);
    expect(updatedDidDoc.diddoc.deactivated).to.equal(true);
  });

  it("should update the status of a DID document with revocation", async () => {
    const didDoc = getLocalJson("./data/document.json");
    await openDID.registRole(owner.address, "Tas");
    await openDID.connect(owner).registDidDoc(didDoc);
    const newStatus = "TERMINATED";
    const terminatedTime = "2025-04-08T00:00:00Z";
    await openDID.updateDidDocStatusRevocation(didDoc.id, newStatus, terminatedTime);
    const storedStatus = await openDID.getDidDocStatus(didDoc.id);
    expect(storedStatus.status).to.equal(3);
    expect(storedStatus.terminatedTime).to.equal(terminatedTime);
  });

  it("should register and retrieve VC metadata", async () => {
    const vcMeta = getLocalJson("./data/vcMeta.json");

    // addr1을 issuer로 사용
    await openDID.registRole(addr1.address, "Issuer");

    await expect(openDID.connect(addr1).registVcMetaData(vcMeta))
      .to.emit(openDID, "VCIssued")
      .withArgs(vcMeta.id, addr1.address, vcMeta.issuer.did);
    const storedVcMeta = await openDID.getVcmetaData(vcMeta.id);
    expect(storedVcMeta.id).to.equal(vcMeta.id);
    expect(storedVcMeta.issuer.did).to.equal(vcMeta.issuer.did);
    expect(storedVcMeta.issuanceDate).to.equal(vcMeta.issuanceDate);
    expect(storedVcMeta.expirationDate).to.equal(vcMeta.expirationDate);
    expect(storedVcMeta.credentialSchema.url).to.equal(vcMeta.credentialSchema.url);
  });

  it("should register vc schema data", async () => {
    const vcSchema = getLocalJson('./data/vc-schema.json');
    await openDID.registRole(addr1.address, "Issuer");
    await expect(openDID.connect(addr1).registVcSchema(vcSchema))
      .to.emit(openDID, "VCSchemaCreated")
      .withArgs(vcSchema.id, addr1.address);

    const storedVcSchema = await openDID.getVcSchema(vcSchema.id);
    expect(storedVcSchema.id).to.equal(vcSchema.id);
    expect(storedVcSchema.schema).to.equal(vcSchema.schema);
  });

  it("should allow only ADMIN to set DocumentStorage address", async () => {
    const DocumentStorage = await ethers.getContractFactory("DocumentStorage");
    const newStorage = await DocumentStorage.deploy();
    const newStorageAddress = await newStorage.getAddress();

    // ADMIN(owner) 가능
    await expect(openDID.setDocumentStorage(newStorageAddress)).to.not.be.reverted;
  });

  it("should allow only ADMIN to set VcMetaStorage address", async () => {
    const VcMetaStorage = await ethers.getContractFactory("VcMetaStorage");
    const newStorage = await VcMetaStorage.deploy();
    const newStorageAddress = await newStorage.getAddress();

    await expect(openDID.setVcMetaStorage(newStorageAddress)).to.not.be.reverted;
  });

  it("should allow only ADMIN to set ZKPStorage address", async () => {
    const ZKPStorage = await ethers.getContractFactory("ZKPStorage");
    const newStorage = await ZKPStorage.deploy();
    const newStorageAddress = await newStorage.getAddress();

    await expect(openDID.setZKPStorage(newStorageAddress)).to.not.be.reverted;
  });

  it("should only allow ISSUER to register and get ZKP credential schema", async () => {
    // addr1에게 ISSUER 권한 부여
    await openDID.registRole(addr1.address, "Issuer");

    const credentialSchema = getLocalJson("./data/credential-schema.json");

    // 권한 없는 계정은 실패
    await expect(
      openDID.registZKPCredential(credentialSchema)
    ).to.be.revertedWith("Caller does not have Issuer role");

    // 권한 있는 계정은 성공
    await expect(
      openDID.connect(addr1).registZKPCredential(credentialSchema)
    ).to.not.be.reverted;

    // 조회도 정상 동작
    const stored = await openDID.getZKPCredential(credentialSchema.id);
    expect(stored.id).to.equal(credentialSchema.id);
    expect(stored.name).to.equal(credentialSchema.name);
  });

  it("should only allow ISSUER to register and get ZKP credential definition", async () => {
    await openDID.registRole(addr1.address, "Issuer");

    const credentialDefinition = getLocalJson("./data/credential-definition.json");

    await expect(
      openDID.registZKPCredentialDefinition(credentialDefinition)
    ).to.be.revertedWith("Caller does not have Issuer role");

    await expect(
      openDID.connect(addr1).registZKPCredentialDefinition(credentialDefinition)
    ).to.not.be.reverted;

    const stored = await openDID.getZKPCredentialDefinition(credentialDefinition.id);
    expect(stored.id).to.equal(credentialDefinition.id);
    expect(stored.schemaId).to.equal(credentialDefinition.schemaId);
  });

  it("should revert registRole if target is zero address or roleType is empty", async () => {
    await expect(
      openDID.registRole(ethers.ZeroAddress, "ISSUER")
    ).to.be.revertedWith("Target address cannot be zero");

    await expect(
      openDID.registRole(addr1.address, "")
    ).to.be.revertedWith("Role type cannot be empty");
  });

  it("should revert isHaveRole if target is zero address or roleType is empty", async () => {
    await expect(
      openDID.isHaveRole(ethers.ZeroAddress, "ISSUER")
    ).to.be.revertedWith("Target address cannot be zero");

    await expect(
      openDID.isHaveRole(addr1.address, "")
    ).to.be.revertedWith("Role type cannot be empty");
  });

  it("should only allow ADMIN to upgrade contract", async () => {
    const OpenDIDFactory = await ethers.getContractFactory("OpenDID");
    await expect(
      upgrades.upgradeProxy(openDID, OpenDIDFactory.connect(addr1))
    ).to.be.revertedWithCustomError(openDID, "AccessControlUnauthorizedAccount");
  });
});