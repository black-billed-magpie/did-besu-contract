// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./data/ZKPLibrary.sol";
import "./data/DocumentLibrary.sol";
import "./data/VcMetaLibrary.sol";
import "./data/VcSchemaMetaLibrary.sol";
import "./data/ResponseLibrary.sol";
import "./data/RoleLibrary.sol";

import "./storage/DocumentStorage.sol";
import "./storage/VcMetaStorage.sol";
import "./storage/ZKPStorage.sol";

import "./utils/MultiBaseLibrary.sol";

contract OpenDID is Initializable, UUPSUpgradeable, AccessControl {
    // Event declaration
    event Setup();
    event DIDCreated(string did, address controller);
    event DIDUpdated(string did, address controller);
    event DIDDeactivated(string did, address controller);
    event VCIssued(string vcId, address issuer, string did);
    event VCStatus(string vcId, address player, string status);
    event VCSchemaCreated(string schemaId, address issuer);

    // Libraries
    using DocumentLibrary for DocumentLibrary.Document;
    using VcMetaLibrary for VcMetaLibrary.VcMeta;
    using VcSchemaMetaLibrary for VcSchemaMetaLibrary.VcSchema;
    using ZKPLibrary for ZKPLibrary.CredentialSchema;
    using ZKPLibrary for ZKPLibrary.CredentialDefinition;
    using ResponseLibrary for ResponseLibrary.Response;

    // Storage contracts
    DocumentStorage private documentStorage;
    VcMetaStorage private vcMetaStorage;
    ZKPStorage private zkpStorage;

    function initialize(
        address _documentStorage,
        address _vcMetaStorage,
        address _zkpStorage
    ) public initializer {
        _grantRole(RoleLibrary.ADMIN_ROLE, _msgSender());
        __UUPSUpgradeable_init();

        require(
            _documentStorage != address(0),
            "Invalid DocumentStorage address"
        );

        require(_vcMetaStorage != address(0), "Invalid VcMetaStorage address");
        require(_zkpStorage != address(0), "Invalid ZKPStorage address");

        documentStorage = DocumentStorage(_documentStorage);
        vcMetaStorage = VcMetaStorage(_vcMetaStorage);
        zkpStorage = ZKPStorage(_zkpStorage);

        emit Setup();
    }

    function hasInitialized() public view returns (bool) {
        return _getInitializedVersion() > 0;
    }

    function _authorizeUpgrade(
        address newImplement
    ) internal override onlyRole(RoleLibrary.ADMIN_ROLE) {}

    function setDocumentStorage(
        address _documentStorage
    ) public onlyRole(RoleLibrary.ADMIN_ROLE) {
        documentStorage = DocumentStorage(_documentStorage);
    }

    function setVcMetaStorage(
        address _vcMetaStorage
    ) public onlyRole(RoleLibrary.ADMIN_ROLE) {
        vcMetaStorage = VcMetaStorage(_vcMetaStorage);
    }

    function setZKPStorage(
        address _zkpStorage
    ) public onlyRole(RoleLibrary.ADMIN_ROLE) {
        zkpStorage = ZKPStorage(_zkpStorage);
    }

    function registDidDoc(
        DocumentLibrary.Document calldata _invokedDidDoc,
        string calldata roleType
    ) public returns (string memory) {
        // Decode the public key from the DID Document
        bytes memory publicKeyValue = MultiBaseLibrary.decode(
            _invokedDidDoc.verificationMethod[0].publicKeyMultibase
        );

        // Derive the Ethereum address from the public key
        address registPlayer = _deriveAddressFromPublicKey(publicKeyValue);

        // Attempt to register the document in storage
        try
            documentStorage.registerDocument(_invokedDidDoc, msg.sender)
        returns (bool isSuccess) {
            require(isSuccess, "Document registration failed");

            // Emit event and assign role
            emit DIDCreated(_invokedDidDoc.id, msg.sender);
            _grantRole(keccak256(abi.encodePacked(roleType)), registPlayer);

            // Return the document as JSON
            return DocumentLibrary.documentToJson(_invokedDidDoc);
        } catch Error(string memory reason) {
            revert(reason); // Revert with the specific error reason
        } catch {
            revert("Unknown error occurred during document registration");
        }
    }

    // Helper function to derive an Ethereum address from a public key
    function _deriveAddressFromPublicKey(
        bytes memory publicKey
    ) private pure returns (address) {
        bytes32 hashKey = keccak256(publicKey);
        return address(uint160(uint256(hashKey)));
    }

    function getDidDoc(
        string calldata _did
    ) public view returns (ResponseLibrary.Response memory) {
        // Try to retrieve the DID Document from the storage contract
        try documentStorage.getDocument(_did) returns (
            DocumentLibrary.Document memory document
        ) {
            // Convert the retrieved document to a JSON string
            string memory documentJson = DocumentLibrary.documentToJson(
                document
            );

            // Return a successful response with the document data
            return
                ResponseLibrary.Response(
                    200,
                    "Document retrieved successfully",
                    documentJson
                );
            // Catch and handle specific errors thrown by the storage contract
        } catch Error(string memory reason) {
            // Revert the transaction with the specific error reason
            revert(reason);
        } catch {
            // Revert the transaction with a generic error message
            revert("Unknown error occurred during document retrieval");
        }
    }

    function getDidDocStatus(
        string calldata _did
    ) public view returns (DocumentLibrary.DocumentStatus memory) {
        require(
            bytes(_did).length > 0,
            "DocumentStorage: Document ID cannot be empty"
        );

        DocumentLibrary.DocumentStatus memory documentStatus = documentStorage
            .getDocumentStatus(_did);
        return documentStatus;
    }

    function updateDidDocStatusInService(
        string calldata _did,
        string calldata _status,
        string calldata _versionId
    ) public {
        try documentStorage.getDocument(_did, _versionId) returns (
            DocumentLibrary.Document memory document
        ) {
            // check params
            require(
                bytes(_did).length > 0,
                "DocumentStorage: Document id cannot be empty"
            );
            require(
                bytes(_status).length > 0,
                "DocumentStorage: Document status cannot be empty"
            );

            // update document status
            DocumentLibrary.setActivated(document, _status);

            // store document status
            documentStorage.updateDocument(document, _did, _versionId);
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("Unknown error occurred during document retrieval");
        }
    }

    function updateDidDocStatusRevocation(
        string calldata _did,
        string calldata _status,
        string calldata _terminatedTime
    ) public {
        try documentStorage.getDocumentStatus(_did) returns (
            DocumentLibrary.DocumentStatus memory documentStatus
        ) {
            // 문서 상태 업데이트
            DocumentLibrary.updateStatus(
                documentStatus,
                _status,
                _terminatedTime
            );

            // 문서 상태 저장
            documentStorage.updateDocumentStatus(documentStatus, _did);
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("Unknown error occurred during document retrieval");
        }
    }

    function registVcMetaData(VcMetaLibrary.VcMeta calldata _vcMeta) public {
        vcMetaStorage.registerVcMeta(_vcMeta);
        emit VCIssued(_vcMeta.id, msg.sender, _vcMeta.issuer.did);
    }

    function getVcmetaData(
        string calldata _id
    ) public view returns (VcMetaLibrary.VcMeta memory) {
        try vcMetaStorage.getVcMeta(_id) returns (
            VcMetaLibrary.VcMeta memory vcMeta
        ) {
            return vcMeta;
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("Unknown error occurred during VC metadata retrieval");
        }
    }

    function updateVcStats(
        string calldata _vcId,
        string calldata _status
    ) public {
        vcMetaStorage.updateVcMetaStatus(_vcId, _status);
        emit VCStatus(_vcId, msg.sender, _status);
    }

    function registVcSchema(
        VcSchemaMetaLibrary.VcSchema calldata _vcSchema
    ) public {
        require(bytes(_vcSchema.id).length > 0, "Schema ID cannot be empty");
        require(
            bytes(_vcSchema.schema).length > 0,
            "Schema URL cannot be empty"
        );
        require(
            bytes(_vcSchema.title).length > 0,
            "Schema title cannot be empty"
        );

        vcMetaStorage.registerVcSchema(_vcSchema);
        emit VCSchemaCreated(_vcSchema.id, msg.sender);
    }

    function getVcSchema(
        string calldata _id
    ) public view returns (VcSchemaMetaLibrary.VcSchema memory) {
        try vcMetaStorage.getVcSchema(_id) returns (
            VcSchemaMetaLibrary.VcSchema memory vcSchema
        ) {
            return vcSchema;
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("Unknown error occurred during VC schema retrieval");
        }
    }

    function registZKPCredential(
        ZKPLibrary.CredentialSchema calldata _credentialSchema
    ) public {
        zkpStorage.registerSchema(_credentialSchema);
    }

    function getZKPCredential(
        string calldata _id
    ) public view returns (ZKPLibrary.CredentialSchema memory) {
        try zkpStorage.getSchema(_id) returns (
            ZKPLibrary.CredentialSchema memory credentialSchema
        ) {
            return credentialSchema;
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("Unknown error occurred during ZKP credential retrieval");
        }
    }

    function registZKPCredentialDefinition(
        ZKPLibrary.CredentialDefinition calldata _credentialDefinition
    ) public {
        zkpStorage.registerCredentialDefinition(_credentialDefinition);
    }

    function getZKPCredentialDefinition(
        string calldata _id
    ) public view returns (ZKPLibrary.CredentialDefinition memory) {
        try zkpStorage.getCredentialDefinition(_id) returns (
            ZKPLibrary.CredentialDefinition memory credentialDefinition
        ) {
            return credentialDefinition;
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert(
                "Unknown error occurred during ZKP credential definition retrieval"
            );
        }
    }
}
