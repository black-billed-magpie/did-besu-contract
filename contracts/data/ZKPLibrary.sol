// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title ZKPLibrary
 * @dev Library for Zero-Knowledge Proof (ZKP) credential schemas and definitions, including attribute types and internationalization support.
 */
library ZKPLibrary {
    /**
     * @dev Structure representing a credential schema.
     * @param id The schema ID.
     * @param name The schema name.
     * @param version The schema version.
     * @param attrNames The attribute names.
     * @param attrTypes The attribute types.
     * @param tag The schema tag.
     */
    struct CredentialSchema {
        string id;
        string name;
        string version;
        string[] attrNames;
        AttributeType[] attrTypes;
        string tag;
    }

    /**
     * @dev Converts a CredentialSchema struct to a JSON string.
     * @param schema The credential schema struct.
     * @return The JSON string representation.
     */
    function extractCredentialSchemaJson(
        CredentialSchema memory schema
    ) internal pure returns (string memory) {
        string memory attributes = "[";
        for (uint256 i = 0; i < schema.attrNames.length; i++) {
            attributes = string(
                abi.encodePacked(attributes, '"', schema.attrNames[i], '"')
            );
            if (i < schema.attrNames.length - 1) {
                attributes = string(abi.encodePacked(attributes, ","));
            }
        }
        attributes = string(abi.encodePacked(attributes, "]"));

        return
            string(
                abi.encodePacked(
                    "{",
                    '"id":"',
                    schema.id,
                    '",',
                    '"name":"',
                    schema.name,
                    '",',
                    '"version":"',
                    schema.version,
                    '",',
                    '"attributeName":',
                    attributes,
                    ",",
                    '"tag":"',
                    schema.tag,
                    '"',
                    "}"
                )
            );
    }

    /**
     * @dev Structure representing a credential definition.
     * @param id The definition ID.
     * @param schemaId The associated schema ID.
     * @param ver The version.
     * @param _type The type.
     * @param value The value.
     * @param tag The tag.
     */
    struct CredentialDefinition {
        string id;
        string schemaId;
        string ver;
        string _type;
        string value;
        string tag;
    }

    /**
     * @dev Structure representing an attribute type, including namespace and items.
     */
    struct AttributeType {
        AttributeNamespace namespace;
        AttributeItem[] items;
    }

    /**
     * @dev Structure representing an attribute namespace.
     */
    struct AttributeNamespace {
        string id;
        string name;
        string ref;
    }

    /**
     * @dev Structure representing an attribute item, including label, caption, type, and i18n.
     */
    struct AttributeItem {
        string label;
        string caption;
        string _type;
        Internationalization[] i18n;
    }

    /**
     * @dev Structure representing internationalization for attribute items.
     */
    struct Internationalization {
        string languageType;
        string value;
    }
}
