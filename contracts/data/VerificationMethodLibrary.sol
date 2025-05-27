// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title VerificationMethodLibrary
 * @dev Library for handling verification methods, key types, and authentication types for DIDs.
 */
library VerificationMethodLibrary {
    /**
     * @dev Enum representing supported key types for verification methods.
     */
    enum KeyType {
        RsaVerificationKey2018,
        Secp256k1VerificationKey2018,
        Secp256r1VerificationKey2018
    }

    /**
     * @dev Enum representing supported authentication types.
     */
    enum AuthType {
        Free,
        PIN,
        BIO
    }

    /**
     * @dev Structure representing a verification method for a DID.
     * @param id The verification method ID.
     * @param keyType The key type used.
     * @param controller The controller address or DID.
     * @param publicKeyMultibase The public key in multibase format.
     * @param authType The authentication type.
     */
    struct VerificationMethod {
        string id;
        KeyType keyType;
        string controller;
        string publicKeyMultibase;
        AuthType authType;
    }

    /**
     * @dev Compares two VerificationMethod structs for equality.
     * @param a The first VerificationMethod.
     * @param b The second VerificationMethod.
     * @return True if equal, false otherwise.
     */
    function equals(
        VerificationMethod memory a,
        VerificationMethod memory b
    ) internal pure returns (bool) {
        return
            keccak256(
                abi.encodePacked(
                    a.id,
                    a.keyType,
                    a.controller,
                    a.publicKeyMultibase,
                    a.authType
                )
            ) ==
            keccak256(
                abi.encodePacked(
                    b.id,
                    b.keyType,
                    b.controller,
                    b.publicKeyMultibase,
                    b.authType
                )
            );
    }

    /**
     * @dev Converts a VerificationMethod struct to a JSON string.
     * @param method The VerificationMethod struct.
     * @return The JSON string representation.
     */
    function toJson(
        VerificationMethod memory method
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"id":"',
                    method.id,
                    '","keyType":"',
                    method.keyType,
                    '","controller":"',
                    method.controller,
                    '","publicKeyMultibase":"',
                    method.publicKeyMultibase,
                    '","authType":"',
                    method.authType,
                    '"}'
                )
            );
    }

    /**
     * @dev Computes a hash of the VerificationMethod struct.
     * @param verificationMethod The VerificationMethod struct.
     * @return The sha256 hash.
     */
    function toHash(
        VerificationMethod memory verificationMethod
    ) internal pure returns (bytes32) {
        return
            sha256(
                abi.encodePacked(
                    verificationMethod.id,
                    verificationMethod.keyType,
                    verificationMethod.controller,
                    verificationMethod.publicKeyMultibase,
                    verificationMethod.authType
                )
            );
    }

    /**
     * @dev Converts a KeyType enum value to its string representation.
     * @param keyType The KeyType value.
     * @return The string representation.
     */
    function keyTypeToString(
        KeyType keyType
    ) internal pure returns (string memory) {
        if (keyType == KeyType.RsaVerificationKey2018) {
            return "RsaVerificationKey2018";
        } else if (keyType == KeyType.Secp256k1VerificationKey2018) {
            return "Secp256k1VerificationKey2018";
        } else if (keyType == KeyType.Secp256r1VerificationKey2018) {
            return "Secp256r1VerificationKey2018";
        } else {
            return "";
        }
    }

    /**
     * @dev Converts an AuthType enum value to an integer representation.
     * @param authType The AuthType value.
     * @return The integer representation.
     */
    function authTypeToInt(AuthType authType) internal pure returns (int) {
        if (authType == AuthType.Free) {
            return 1;
        } else if (authType == AuthType.PIN) {
            return 2;
        } else if (authType == AuthType.BIO) {
            return 4;
        } else {
            return 0;
        }
    }
}
