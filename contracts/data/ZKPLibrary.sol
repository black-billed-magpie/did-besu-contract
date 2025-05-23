// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library ZKPLibrary {
    struct CredentialSchema {
        string id;
        string name;
        string version;
        string[] attrNames;
        AttributeType[] attrTypes;
        string tag;
    }

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

    struct CredentialDefinition {
        string id;
        string schemaId;
        string ver;
        string _type;
        string value;
        string tag;
    }

    struct AttributeType {
        AttributeNamespace namespace;
        AttributeItem[] items;
    }

    struct AttributeNamespace {
        string id;
        string name;
        string ref;
    }

    struct AttributeItem {
        string label;
        string caption;
        string _type;
        Internationalization[] i18n;
    }

    struct Internationalization {
        string languageType;
        string value;
    }
}
