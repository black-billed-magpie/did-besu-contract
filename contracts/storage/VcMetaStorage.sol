// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../data/VcMetaLibrary.sol";
import "../data/VcSchemaMetaLibrary.sol";

contract VcMetaStorage is Initializable {
    using VcMetaLibrary for VcMetaLibrary.VcMeta;
    using VcSchemaMetaLibrary for VcSchemaMetaLibrary.VcSchema;

    event VcMetaStorageSetup();
    event VcMetaRegistered(string _id, string _vcMetaJson);

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        emit VcMetaStorageSetup();
    }

    function hasInitialized() public view returns (bool) {
        return _getInitializedVersion() > 0;
    }

    struct Storage {
        mapping(string => VcMetaLibrary.VcMeta) _vcMeta;
        mapping(string => VcSchemaMetaLibrary.VcSchema) _vcSchemas;
    }

    address internal _implementation;
    address internal _admin;
    bytes32 internal constant STORAGE_LOCATION =
        keccak256("openDID.storage.VcMetaStorage");

    function _getStorage() private pure returns (Storage storage store) {
        bytes32 position = STORAGE_LOCATION;
        assembly {
            store.slot := position
        }
    }

    function registerVcMeta(VcMetaLibrary.VcMeta calldata _vcMeta) external {
        Storage storage store = _getStorage();

        require(
            bytes(_vcMeta.id).length > 0,
            "VcMetaStorage: ID of vcmeta cannot be empty"
        );
        store._vcMeta[_vcMeta.id] = _vcMeta;

        string memory vcMetaJson = VcMetaLibrary.toJson(_vcMeta);
        emit VcMetaRegistered(_vcMeta.id, vcMetaJson);
    }

    function getVcMeta(
        string calldata _vcMetaId
    ) external view returns (VcMetaLibrary.VcMeta memory) {
        Storage storage store = _getStorage();

        require(
            bytes(_vcMetaId).length > 0,
            "VcMetaStorage: ID of vcmeta cannot be empty"
        );

        require(_isExist(_vcMetaId), "VcMetaStorage: VcMeta does not exist");

        return store._vcMeta[_vcMetaId];
    }

    function _isExist(string calldata _id) internal view returns (bool) {
        Storage storage store = _getStorage();
        // Check if the data exists
        return bytes(store._vcMeta[_id].id).length > 0;
    }

    function updateVcMetaStatus(
        string calldata _vcId,
        string calldata _status // "active", "inactive", "revoked"
    ) external {
        Storage storage store = _getStorage();
        VcMetaLibrary.VcMeta storage vcMeta = store._vcMeta[_vcId];
        VcMetaLibrary.updateVcStatus(vcMeta, _status);
    }

    function registerVcSchema(
        VcSchemaMetaLibrary.VcSchema calldata _vcSchema
    ) external {
        Storage storage store = _getStorage();

        require(
            bytes(_vcSchema.id).length > 0,
            "VcMetaStorage: ID of vcschema cannot be empty"
        );

        store._vcSchemas[_vcSchema.id] = _vcSchema;

        string memory vcSchemaJson = VcSchemaMetaLibrary.toJson(_vcSchema);
        emit VcMetaRegistered(_vcSchema.id, vcSchemaJson);
    }

    function getVcSchema(
        string calldata _vcSchemaId
    ) external view returns (VcSchemaMetaLibrary.VcSchema memory) {
        Storage storage store = _getStorage();

        require(
            bytes(_vcSchemaId).length > 0,
            "VcMetaStorage: ID of vcschema cannot be empty"
        );

        require(
            _isExistSchema(_vcSchemaId),
            "VcMetaStorage: VcSchema does not exist"
        );

        return store._vcSchemas[_vcSchemaId];
    }

    function _isExistSchema(string calldata _id) internal view returns (bool) {
        Storage storage store = _getStorage();
        // Check if the data exists
        return bytes(store._vcSchemas[_id].id).length > 0;
    }

    function deleteVcSchema(string calldata _vcSchemaId) external {
        Storage storage store = _getStorage();
        delete store._vcSchemas[_vcSchemaId];
    }
}
