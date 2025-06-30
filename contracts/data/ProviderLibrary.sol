// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title ProviderLibrary
 * @dev Library for handling provider information, equality checks, and JSON serialization for Verifiable Credentials.
 */
library ProviderLibrary {
    /**
     * @dev Structure representing a provider.
     * @param did The provider's DID.
     * @param certVcReference The provider's certificate VC reference.
     */
    struct Provider {
        string did;
        string certVcReference;
    }

    /**
     * @dev Compares two Provider structs for equality.
     * @param a The first Provider struct.
     * @param b The second Provider struct.
     * @return True if equal, false otherwise.
     */
    function equals(
        Provider memory a,
        Provider memory b
    ) internal pure returns (bool) {
        if (
            keccak256(abi.encodePacked(a.did)) !=
            keccak256(abi.encodePacked(b.did)) ||
            keccak256(abi.encodePacked(a.certVcReference)) !=
            keccak256(abi.encodePacked(b.certVcReference))
        ) {
            return false;
        }

        return true;
    }

    /**
     * @dev Converts a Provider struct to a JSON string.
     * @param provider The Provider struct.
     * @return The JSON string representation.
     */
    function toJson(
        Provider memory provider
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"did":"',
                    provider.did,
                    '","certVcReference":"',
                    provider.certVcReference,
                    '"}'
                )
            );
    }
}
