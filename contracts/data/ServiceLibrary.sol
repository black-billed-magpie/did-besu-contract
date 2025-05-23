// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library ServiceLibrary {
    enum DID_SERVICE_TYPE {
        LINKED_DOMAINS,
        CREDENTIAL_REGISTRY
    }

    struct Service {
        string id;
        string serviceType;
        string[] serviceEndpoint;
    }

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
