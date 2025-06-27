// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title VcSchemaMetaLibrary
 * @dev Library for handling Verifiable Credential (VC) schema metadata, claims, namespaces, and JSON serialization.
 */
library VcSchemaMetaLibrary {
    /**
     * @dev Structure representing metadata for a VC schema.
     * @param formatVersion The format version string.
     * @param language The language code.
     */
    struct MetaData {
        string formatVersion;
        string language;
    }

    /**
     * @dev Structure representing an item in a schema claim.
     * @param caption The display caption.
     * @param format The data format.
     * @param hideValue Whether to hide the value.
     * @param id The item ID.
     * @param _type The type of the item.
     */
    struct SchemaClaimItem {
        string caption;
        string format;
        bool hideValue;
        string id;
        string _type;
    }

    /**
     * @dev Structure representing a claim namespace.
     * @param id The namespace ID.
     * @param name The namespace name.
     * @param ref The reference URL or string.
     */
    struct ClaimNamespace {
        string id;
        string name;
        string ref;
    }

    /**
     * @dev Structure representing a VC schema claim, including items and namespace.
     * @param items The array of claim items.
     * @param namespace The claim namespace.
     */
    struct VCSchemaClaim {
        SchemaClaimItem[] items;
        ClaimNamespace namespace;
    }

    /**
     * @dev Structure representing the credential subject, which contains claims.
     * @param claims The array of VC schema claims.
     */
    struct CredentialSubject {
        VCSchemaClaim[] claims;
    }

    /**
     * @dev Structure representing a VC schema.
     * @param id The schema ID.
     * @param schema The schema URL or identifier.
     * @param title The schema title.
     * @param description The schema description.
     * @param metadata The schema metadata.
     * @param credentialSubject The credential subject structure.
     */
    struct VcSchema {
        string id;
        string schema;
        string title;
        string description;
        MetaData metadata;
        CredentialSubject credentialSubject;
    }

    /**
     * @dev Converts a VcSchema struct to a JSON string.
     * @param vcSchema The VcSchema struct.
     * @return The JSON string representation.
     */
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

    /**
     * @dev Converts an array of VCSchemaClaim structs to a JSON string.
     * @param claims The array of VCSchemaClaim structs.
     * @return The JSON string representation.
     */
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

    /**
     * @dev Converts an array of SchemaClaimItem structs to a JSON string.
     * @param items The array of SchemaClaimItem structs.
     * @return The JSON string representation.
     */
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
