// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title CredentialSchemaLibrary
 * @dev Library for handling credential schema information, equality checks, and JSON serialization for Verifiable Credentials.
 */
library CredentialSchemaLibrary {
    /**
     * @dev Structure representing a credential schema.
     * @param id The schema URL or identifier.
     * @param credentialSchemaType The type of the credential schema.
     */
    struct CredentialSchema {
        string id;
        string credentialSchemaType;
    }

    /**
     * @dev Converts a CredentialSchema struct to a JSON string.
     * @param schema The CredentialSchema struct.
     * @return The JSON string representation.
     */
    function toJson(
        CredentialSchema memory schema
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"url":"',
                    schema.id,
                    '","credentialSchemaType":"',
                    schema.credentialSchemaType,
                    '"}'
                )
            );
    }

    /**
     * @dev Compares two CredentialSchema structs for equality.
     * @param a The first CredentialSchema struct.
     * @param b The second CredentialSchema struct.
     * @return True if equal, false otherwise.
     */
    function equals(
        CredentialSchema memory a,
        CredentialSchema memory b
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(a.id, a.credentialSchemaType)) ==
            keccak256(abi.encodePacked(b.id, b.credentialSchemaType));
    }
}
