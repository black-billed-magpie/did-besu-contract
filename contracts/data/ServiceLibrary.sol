// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title ServiceLibrary
 * @dev Library for handling DID service endpoints, types, and JSON serialization.
 */
library ServiceLibrary {
    /**
     * @dev Enum representing supported DID service types.
     */
    enum DID_SERVICE_TYPE {
        LINKED_DOMAINS,
        CREDENTIAL_REGISTRY
    }

    /**
     * @dev Structure representing a DID service entry.
     * @param id The service ID.
     * @param serviceType The type of service.
     * @param serviceEndpoint The array of service endpoint URLs or values.
     */
    struct Service {
        string id;
        string serviceType;
        string[] serviceEndpoint;
    }

    /**
     * @dev Converts a Service struct to a JSON string.
     * @param service The Service struct.
     * @return The JSON string representation.
     */
    function toJson(
        Service memory service
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"id":"',
                    service.id,
                    '","serviceType":"',
                    service.serviceType,
                    '","serviceEndpoint":[',
                    _stringArrayToJson(service.serviceEndpoint),
                    "]}"
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
     * @dev Compares two Service structs for equality.
     * @param a The first Service struct.
     * @param b The second Service struct.
     * @return True if equal, false otherwise.
     */
    function equals(
        Service memory a,
        Service memory b
    ) internal pure returns (bool) {
        if (
            keccak256(abi.encodePacked(a.id)) !=
            keccak256(abi.encodePacked(b.id)) ||
            keccak256(abi.encodePacked(a.serviceType)) !=
            keccak256(abi.encodePacked(b.serviceType)) ||
            a.serviceEndpoint.length != b.serviceEndpoint.length
        ) {
            return false;
        }

        for (uint256 i = 0; i < a.serviceEndpoint.length; i++) {
            if (
                keccak256(abi.encodePacked(a.serviceEndpoint[i])) !=
                keccak256(abi.encodePacked(b.serviceEndpoint[i]))
            ) {
                return false;
            }
        }

        return true;
    }
}
