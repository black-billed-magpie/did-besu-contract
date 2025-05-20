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

    const documentStorageAddress = await documentStorage.getAddress();
    const vcMetaStorageAddress = await vcMetaStorage.getAddress();
    const zkpStorageAddress = await zkpStorage.getAddress();

    // OpenDID 배포
    const OpenDIDFactory = await ethers.getContractFactory("OpenDID");
    openDID = await upgrades.deployProxy(OpenDIDFactory, [documentStorageAddress, vcMetaStorageAddress, zkpStorageAddress], { kind: "uups" });
    await openDID.waitForDeployment();
  });

  it("should initialize the OpenDID contract", async () => {
    const initialized = await openDID.hasInitialized();
    expect(initialized).to.be.true;
  });

  it("should register a DID document", async () => {
    const didDoc = getLocalJson("./data/document.json");

    await expect(openDID.registDidDoc(didDoc, "Admin"))
      .to.emit(openDID, "DIDCreated")
      .withArgs(didDoc.id, owner.address);

    const storedDocumentAndStatus = await openDID.getDidDoc(didDoc.id);

    expect(storedDocumentAndStatus.diddoc.id).to.equal(didDoc.id);
    expect(storedDocumentAndStatus.status).to.equal(0);
  });

  it("should not search for a non-existent DID document", async () => {
    const didDocId = "nonExistentDidDocId";
    await expect(openDID.getDidDoc(didDocId))
      .to.be.revertedWith("Document is not exist");
  });

  it("should update the status of a DID document in service", async () => {
    const didDoc = getLocalJson("./data/document.json");

    // DID 문서 등록
    await openDID.registDidDoc(didDoc, "Admin");

    // 상태 업데이트
    const newStatus = "DEACTIVATED";
    const versionId = didDoc.versionId;

    await openDID.updateDidDocStatusInService(didDoc.id, newStatus, versionId);

    const updatedDidDoc = await openDID.getDidDoc(didDoc.id);
    expect(updatedDidDoc.diddoc.deactivated).to.equal(true); // 상태가 비활성화로 변경되었는지 확인
  });

  it("should update the status of a DID document with revocation", async () => {
    const didDoc = getLocalJson("./data/document.json");

    // DID 문서 등록
    await openDID.registDidDoc(didDoc, "Admin");

    // 상태 업데이트
    const newStatus = "TERMINATED";
    const terminatedTime = "2025-04-08T00:00:00Z";

    await openDID.updateDidDocStatusRevocation(didDoc.id, newStatus, terminatedTime);

    const storedStatus = await openDID.getDidDocStatus(didDoc.id);
    expect(storedStatus.status).to.equal(3); // TERMINATED 상태 확인
    expect(storedStatus.terminatedTime).to.equal(terminatedTime);
  });

  it("should register and retrieve VC metadata", async () => {
    const vcMeta = getLocalJson("./data/vcMeta.json");

    // VC 메타데이터 등록
    await expect(openDID.registVcMetaData(vcMeta))
      .to.emit(openDID, "VCIssued")
      .withArgs(vcMeta.id, owner.address, vcMeta.issuer.did);

    // VC 메타데이터 조회
    const storedVcMeta = await openDID.getVcmetaData(vcMeta.id);
    expect(storedVcMeta.id).to.equal(vcMeta.id);
    expect(storedVcMeta.issuer.did).to.equal(vcMeta.issuer.did);
    expect(storedVcMeta.issuanceDate).to.equal(vcMeta.issuanceDate);
    expect(storedVcMeta.expirationDate).to.equal(vcMeta.expirationDate);
    expect(storedVcMeta.credentialSchema.url).to.equal(vcMeta.credentialSchema.url);
  });

  it("should register vc schema data", async () => {
    const vcSchema = getLocalJson('./data/vc-schema.json');

    await expect(openDID.registVcSchema(vcSchema))
      .to.emit(openDID, "VCSchemaCreated")
      .withArgs(vcSchema.id, owner.address);
  });

  it("should get vc schema data", async () => {
    const vcSchema = getLocalJson('./data/vc-schema.json');

    await openDID.registVcSchema(vcSchema);

    const storedVcSchema = await openDID.getVcSchema(vcSchema.id);
    expect(storedVcSchema.id).to.equal(vcSchema.id);
    expect(storedVcSchema.schema).to.equal(vcSchema.schema);
  });

});