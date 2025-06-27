// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title StringUtils
 * @dev Utility library for string and uint256 conversions and comparisons in Solidity.
 */
library StringUtils {
    /**
     * @dev Converts a uint256 value to its decimal string representation.
     * @param _value The uint256 value to convert.
     * @return The string representation of the value.
     */
    function toString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_value % 10)));
            _value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a string containing only digits to a uint256 value.
     * @param _s The string to convert.
     * @return The uint256 value.
     */
    function stringToUint(string memory _s) internal pure returns (uint256) {
        bytes memory b = bytes(_s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            require(
                b[i] >= 0x30 && b[i] <= 0x39,
                "Invalid character in string"
            ); // Ensure it's a digit
            result = result * 10 + (uint256(uint8(b[i])) - 48);
        }
        return result;
    }

    /**
     * @dev Compares two strings for equality.
     * @param _a The first string.
     * @param _b The second string.
     * @return True if the strings are equal, false otherwise.
     */
    function isEqual(
        string calldata _a,
        string calldata _b
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}
