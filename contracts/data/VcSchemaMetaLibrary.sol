// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library VcSchemaMetaLibrary {
    struct MetaData {
        string formatVersion;
        string language;
    }

    struct SchemaClaimItem {
        string caption;
        string format;
        bool hideValue;
        string id;
        string _type;
    }

    struct ClaimNamespace {
        // Fixed typo: CliamNamespace -> ClaimNamespace
        string id;
        string name;
        string ref;
    }

    struct VCSchemaClaim {
        SchemaClaimItem[] items;
        ClaimNamespace namespace;
    }

    struct CredentialSubject {
        VCSchemaClaim[] claims;
    }

    struct VcSchema {
        string id;
        string schema;
        string title;
        string description;
        MetaData metadata;
        CredentialSubject credentialSubject;
    }

    function toJson(
        VcSchema memory vcSchema
    ) internal pure returns (string memory) {
        string memory json = string(
            abi.encodePacked(
                "{",
                '"@id":"',
                vcSchema.id,
                '",',
                '"@schema":"',
                vcSchema.schema,
                '",',
                '"credentialSubject":{',
                '"claims":[',
                _claimsToJson(vcSchema.credentialSubject.claims),
                "]",
                "},",
                '"description":"',
                vcSchema.description,
                '",',
                '"metadata":{',
                '"formatVersion":"',
                vcSchema.metadata.formatVersion,
                '",',
                '"language":"',
                vcSchema.metadata.language,
                '"',
                "},",
                '"title":"',
                vcSchema.title,
                '"',
                "}"
            )
        );
        return json;
    }

    function _claimsToJson(
        VCSchemaClaim[] memory claims
    ) private pure returns (string memory) {
        string memory claimsJson = "";
        for (uint i = 0; i < claims.length; i++) {
            string memory claimJson = string(
                abi.encodePacked(
                    "{",
                    '"items":[',
                    _itemsToJson(claims[i].items),
                    "],",
                    '"namespace":{',
                    '"id":"',
                    claims[i].namespace.id,
                    '",',
                    '"name":"',
                    claims[i].namespace.name,
                    '",',
                    '"ref":"',
                    claims[i].namespace.ref,
                    '"',
                    "}",
                    "}"
                )
            );
            claimsJson = i == 0
                ? claimJson
                : string(abi.encodePacked(claimsJson, ",", claimJson));
        }
        return claimsJson;
    }

    function _itemsToJson(
        SchemaClaimItem[] memory items
    ) private pure returns (string memory) {
        string memory itemsJson = "";
        for (uint i = 0; i < items.length; i++) {
            string memory itemJson = string(
                abi.encodePacked(
                    "{",
                    '"caption":"',
                    items[i].caption,
                    '",',
                    '"format":"',
                    items[i].format,
                    '",',
                    '"hideValue":"',
                    items[i].hideValue,
                    '",',
                    '"id":"',
                    items[i].id,
                    '"',
                    '"type":"',
                    items[i]._type,
                    '",',
                    "}"
                )
            );
            itemsJson = i == 0
                ? itemJson
                : string(abi.encodePacked(itemsJson, ",", itemJson));
        }
        return itemsJson;
    }
}
