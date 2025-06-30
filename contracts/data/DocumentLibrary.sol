// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./ServiceLibrary.sol";
import "./VerificationMethodLibrary.sol";

/**
 * @title DocumentLibrary
 * @dev Library for handling DID Documents, their statuses, and JSON serialization for Verifiable Credentials.
 */
library DocumentLibrary {
    /**
     * @dev Structure representing a DID Document.
     * @param context The array of context strings.
     * @param id The DID Document ID.
     * @param controller The controller DID or address.
     * @param created The creation timestamp.
     * @param updated The update timestamp.
     * @param versionId The version identifier.
     * @param deactivated Whether the DID Document is deactivated.
     * @param verificationMethod The array of verification methods.
     * @param assertionMethod The array of assertion method IDs.
     * @param authentication The array of authentication method IDs.
     * @param keyAgreement The array of key agreement method IDs.
     * @param capabilityInvocation The array of capability invocation method IDs.
     * @param capabilityDelegation The array of capability delegation method IDs.
     * @param services The array of service endpoints.
     */
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

    /**
     * @dev Sets the deactivated status of a DID Document based on a status string.
     * @param _document The DID Document to update.
     * @param _status The status string ("ACTIVATED" or "DEACTIVATED").
     */
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

    /**
     * @dev Converts a Document struct to a JSON string.
     * @param doc The Document struct.
     * @return The JSON string representation.
     */
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

    /**
     * @dev Converts an array of strings to a JSON array string.
     * @param array The array of strings.
     * @return The JSON array string.
     */
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

    /**
     * @dev Enum representing possible DID Document statuses.
     */
    enum DIDDOC_STATUS {
        ACTIVATED,
        DEACTIVATED,
        REVOKED,
        TERMINATED
    }

    /**
     * @dev Structure representing the status of a DID Document.
     * @param id The document ID.
     * @param status The document status (enum).
     * @param version The version string.
     * @param roleType The role type string.
     * @param terminatedTime The terminated time string.
     */
    struct DocumentStatus {
        string id;
        DIDDOC_STATUS status;
        string version;
        string roleType;
        string terminatedTime;
    }

    /**
     * @dev Converts a DocumentStatus struct to a JSON string.
     * @param doc The DocumentStatus struct.
     * @return The JSON string representation.
     */
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

    /**
     * @dev Compares two DocumentStatus structs for equality.
     * @param a The first DocumentStatus struct.
     * @param b The second DocumentStatus struct.
     * @return True if equal, false otherwise.
     */
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

    /**
     * @dev Converts a DIDDOC_STATUS enum value to its string representation.
     * @param status The DIDDOC_STATUS value.
     * @return The string representation.
     */
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

    /**
     * @dev Updates the status and terminated time of a DocumentStatus struct based on a status string.
     * @param _documentStatus The DocumentStatus struct to update.
     * @param _status The new status string.
     * @param _terminatedTime The terminated time string.
     */
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

    /**
     * @dev Structure representing a DID Document and its status.
     * @param diddoc The DID Document struct.
     * @param status The DIDDOC_STATUS value.
     */
    struct DocumentAndStatus {
        Document diddoc;
        DIDDOC_STATUS status;
    }

    /**
     * @dev Converts a DocumentAndStatus struct to a JSON string.
     * @param doc The DocumentAndStatus struct.
     * @return The JSON string representation.
     */
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
