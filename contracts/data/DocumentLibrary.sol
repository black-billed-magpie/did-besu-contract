// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./ServiceLibrary.sol";
import "./VerificationMethodLibrary.sol";

library DocumentLibrary {
    using ServiceLibrary for ServiceLibrary.Service;
    using VerificationMethodLibrary for VerificationMethodLibrary.VerificationMethod;

    struct Document {
        string[] context;
        string id;
        string controller;
        string created;
        string updated;
        string versionId;
        bool deactivated;
        VerificationMethodLibrary.VerificationMethod[] verificationMethod;
        string[] assertionMethod;
        string[] authentication;
        string[] keyAgreement;
        string[] capabilityInvocation;
        string[] capabilityDelegation;
        ServiceLibrary.Service[] services;
    }

    function setActivated(
        Document memory _document,
        string calldata _status
    ) internal pure {
        if (
            keccak256(abi.encodePacked(_status)) ==
            keccak256(abi.encodePacked("ACTIVATED"))
        ) {
            _document.deactivated = false;
        } else if (
            keccak256(abi.encodePacked(_status)) ==
            keccak256(abi.encodePacked("DEACTIVATED"))
        ) {
            _document.deactivated = true;
        }
    }

    function documentToJson(
        Document memory doc
    ) internal pure returns (string memory) {
        string memory verificationMethods = "[";
        for (uint256 i = 0; i < doc.verificationMethod.length; i++) {
            verificationMethods = string(
                abi.encodePacked(
                    verificationMethods,
                    VerificationMethodLibrary.toJson(doc.verificationMethod[i]),
                    i < doc.verificationMethod.length - 1 ? "," : ""
                )
            );
        }
        verificationMethods = string(
            abi.encodePacked(verificationMethods, "]")
        );

        string memory services = "[";
        for (uint256 i = 0; i < doc.services.length; i++) {
            services = string(
                abi.encodePacked(
                    services,
                    ServiceLibrary.toJson(doc.services[i]),
                    i < doc.services.length - 1 ? "," : ""
                )
            );
        }
        services = string(abi.encodePacked(services, "]"));

        return
            string(
                abi.encodePacked(
                    '{"context":[',
                    _stringArrayToJson(doc.context),
                    '],"id":"',
                    doc.id,
                    '","controller":"',
                    doc.controller,
                    '","created":"',
                    doc.created,
                    '","updated":"',
                    doc.updated,
                    '","versionId":"',
                    doc.versionId,
                    '","deactivated":',
                    doc.deactivated ? "true" : "false",
                    ',"verificationMethod":',
                    verificationMethods,
                    ',"assertionMethod":[',
                    _stringArrayToJson(doc.assertionMethod),
                    '],"authentication":[',
                    _stringArrayToJson(doc.authentication),
                    '],"keyAgreement":[',
                    _stringArrayToJson(doc.keyAgreement),
                    '],"capabilityInvocation":[',
                    _stringArrayToJson(doc.capabilityInvocation),
                    '],"capabilityDelegation":[',
                    _stringArrayToJson(doc.capabilityDelegation),
                    '],"services":',
                    services,
                    "}"
                )
            );
    }

    function _stringArrayToJson(
        string[] memory array
    ) private pure returns (string memory) {
        string memory json = "";
        for (uint256 i = 0; i < array.length; i++) {
            json = string(
                abi.encodePacked(
                    json,
                    '"',
                    array[i],
                    '"',
                    i < array.length - 1 ? "," : ""
                )
            );
        }
        return json;
    }

    enum DIDDOC_STATUS {
        ACTIVATED,
        DEACTIVATED,
        REVOKED,
        TERMINATED
    }

    struct DocumentStatus {
        string id;
        DIDDOC_STATUS status;
        string version;
        string roleType;
        string terminatedTime;
    }

    function toJson(
        DocumentStatus memory doc
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"id":"',
                    doc.id,
                    '","status":"',
                    _statusToString(doc.status),
                    '","version":"',
                    doc.version,
                    '","roleType":"',
                    doc.roleType,
                    '","terminatedTime":"',
                    doc.terminatedTime,
                    '"}'
                )
            );
    }

    function equals(
        DocumentStatus memory a,
        DocumentStatus memory b
    ) internal pure returns (bool) {
        return
            keccak256(
                abi.encodePacked(
                    a.id,
                    a.status,
                    a.version,
                    a.roleType,
                    a.terminatedTime
                )
            ) ==
            keccak256(
                abi.encodePacked(
                    b.id,
                    b.status,
                    b.version,
                    b.roleType,
                    b.terminatedTime
                )
            );
    }

    function _statusToString(
        DIDDOC_STATUS status
    ) private pure returns (string memory) {
        if (status == DIDDOC_STATUS.ACTIVATED) {
            return "ACTIVATED";
        } else if (status == DIDDOC_STATUS.DEACTIVATED) {
            return "DEACTIVATED";
        } else if (status == DIDDOC_STATUS.REVOKED) {
            return "REVOKED";
        } else if (status == DIDDOC_STATUS.TERMINATED) {
            return "TERMINATED";
        } else {
            return "";
        }
    }

    function updateStatus(
        DocumentStatus memory _documentStatus,
        string calldata _status,
        string calldata _terminatedTime
    ) internal pure {
        if (
            keccak256(abi.encodePacked(_status)) ==
            keccak256(abi.encodePacked("ACTIVATED"))
        ) {
            _documentStatus.status = DIDDOC_STATUS.ACTIVATED;
        } else if (
            keccak256(abi.encodePacked(_status)) ==
            keccak256(abi.encodePacked("DEACTIVATED"))
        ) {
            _documentStatus.status = DIDDOC_STATUS.DEACTIVATED;
        } else if (
            keccak256(abi.encodePacked(_status)) ==
            keccak256(abi.encodePacked("REVOKED"))
        ) {
            _documentStatus.status = DIDDOC_STATUS.REVOKED;
        } else if (
            keccak256(abi.encodePacked(_status)) ==
            keccak256(abi.encodePacked("TERMINATED"))
        ) {
            _documentStatus.status = DIDDOC_STATUS.TERMINATED;
            _documentStatus.terminatedTime = _terminatedTime;
        }
    }

    struct DocumentAndStatus {
        Document diddoc;
        DIDDOC_STATUS status;
    }

    function toJson(
        DocumentAndStatus memory doc
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"diddoc":',
                    documentToJson(doc.diddoc),
                    ',"status":"',
                    _statusToString(doc.status),
                    '"}'
                )
            );
    }
}
