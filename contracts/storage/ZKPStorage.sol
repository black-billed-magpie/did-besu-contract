// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../data/ZKPLibrary.sol";

contract ZKPStorage is Initializable {
    using ZKPLibrary for *;

    event ZKPStorageSetup();

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        emit ZKPStorageSetup();
    }

    function hasInitialized() public view returns (bool) {
        return _getInitializedVersion() > 0;
    }

    struct Storage {
        mapping(string => ZKPLibrary.CredentialDefinition) _credentialDefinitions;
        mapping(string => ZKPLibrary.CredentialSchema) _credentialSchemas;
    }
    bytes32 internal constant STORAGE_LOCATION =
        keccak256("openDID.storage.ZKPStorage");

    function _getStorage() private pure returns (Storage storage store) {
        bytes32 position = STORAGE_LOCATION;
        assembly {
            store.slot := position
        }
    }

    function registerCredentialDefinition(
        ZKPLibrary.CredentialDefinition calldata _credentialDefinition
    ) external {
        Storage storage store = _getStorage();
        store._credentialDefinitions[
            _credentialDefinition.id
        ] = _credentialDefinition;
    }

    function getCredentialDefinition(
        string calldata _credentialDefinitionId
    ) external view returns (ZKPLibrary.CredentialDefinition memory) {
        Storage storage store = _getStorage();
        return store._credentialDefinitions[_credentialDefinitionId];
    }

    function removeCredentialDefinition(
        string calldata _credentialDefinitionId
    ) external {
        Storage storage store = _getStorage();
        delete store._credentialDefinitions[_credentialDefinitionId];
    }

    function registerSchema(
        ZKPLibrary.CredentialSchema calldata _schema
    ) external {
        Storage storage store = _getStorage();
        store._credentialSchemas[_schema.id] = _schema;
    }

    function getSchema(
        string calldata _schemaId
    ) external view returns (ZKPLibrary.CredentialSchema memory) {
        Storage storage store = _getStorage();
        return store._credentialSchemas[_schemaId];
    }

    function removeSchema(string calldata _schemaId) external {
        Storage storage store = _getStorage();
        delete store._credentialSchemas[_schemaId];
    }
}
