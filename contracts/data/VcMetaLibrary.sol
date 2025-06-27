// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./ProviderLibrary.sol";
import "./CredentialSchemaLibrary.sol";

/**
 * @title VcMetaLibrary
 * @dev Library for handling Verifiable Credential (VC) metadata, including issuer, subject, schema, status, and serialization.
 */
library VcMetaLibrary {
    using ProviderLibrary for ProviderLibrary.Provider;
    using CredentialSchemaLibrary for CredentialSchemaLibrary.CredentialSchema;

    /**
     * @dev Structure representing VC metadata.
     * @param id The VC ID.
     * @param issuer The issuer (Provider struct).
     * @param subject The subject DID.
     * @param credentialSchema The credential schema (CredentialSchema struct).
     * @param status The VC status string.
     * @param issuanceDate The issuance date string.
     * @param validFrom The valid-from date string.
     * @param validUntil The valid-until date string.
     * @param formatVersion The format version string.
     * @param language The language code.
     */
    struct VcMeta {
        string id;
        ProviderLibrary.Provider issuer;
        string subject;
        CredentialSchemaLibrary.CredentialSchema credentialSchema;
        string status;
        string issuanceDate;
        string validFrom;
        string validUntil;
        string formatVersion;
        string language;
    }

    /**
     * @dev Converts a VcMeta struct to a JSON string.
     * @param meta The VcMeta struct.
     * @return The JSON string representation.
     */
    function toJson(VcMeta memory meta) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"id":"',
                    meta.id,
                    '","issuer":',
                    meta.issuer.toJson(),
                    ',"subject":"',
                    meta.subject,
                    '","credentialSchema":',
                    meta.credentialSchema.toJson(),
                    ',"status":"',
                    meta.status,
                    '","issuanceDate":"',
                    meta.issuanceDate,
                    '","validFrom":"',
                    meta.validFrom,
                    '","validUntil":"',
                    meta.validUntil,
                    '","formatVersion":"',
                    meta.formatVersion,
                    '","language":"',
                    meta.language,
                    '"}'
                )
            );
    }

    /**
     * @dev Compares two VcMeta structs for equality.
     * @param a The first VcMeta struct.
     * @param b The second VcMeta struct.
     * @return True if equal, false otherwise.
     */
    function equals(
        VcMeta memory a,
        VcMeta memory b
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(a.id)) ==
            keccak256(abi.encodePacked(b.id)) &&
            a.issuer.equals(b.issuer) &&
            keccak256(abi.encodePacked(a.subject)) ==
            keccak256(abi.encodePacked(b.subject)) &&
            a.credentialSchema.equals(b.credentialSchema) &&
            keccak256(abi.encodePacked(a.status)) ==
            keccak256(abi.encodePacked(b.status)) &&
            keccak256(abi.encodePacked(a.issuanceDate)) ==
            keccak256(abi.encodePacked(b.issuanceDate)) &&
            keccak256(abi.encodePacked(a.validFrom)) ==
            keccak256(abi.encodePacked(b.validFrom)) &&
            keccak256(abi.encodePacked(a.validUntil)) ==
            keccak256(abi.encodePacked(b.validUntil)) &&
            keccak256(abi.encodePacked(a.formatVersion)) ==
            keccak256(abi.encodePacked(b.formatVersion)) &&
            keccak256(abi.encodePacked(a.language)) ==
            keccak256(abi.encodePacked(b.language));
    }

    /**
     * @dev Updates the status field of a VcMeta struct in storage.
     * @param meta The VcMeta struct in storage.
     * @param _status The new status string.
     */
    function updateVcStatus(
        VcMeta storage meta,
        string memory _status
    ) internal {
        meta.status = _status; // Directly assign the string value
    }
}
