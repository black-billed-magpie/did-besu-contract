// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MultiBaseLibrary {
    string internal constant ALPHABET =
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    function encode(bytes memory input) internal pure returns (string memory) {
        if (input.length == 0) {
            return "";
        }

        // Count leading zeros
        uint256 zeros = 0;
        while (zeros < input.length && input[zeros] == 0) {
            zeros++;
        }

        // Convert base-256 digits to base-58 digits
        bytes memory inputCopy = input; // Solidity automatically handles memory
        bytes memory encoded = new bytes(input.length * 2); // upper bound
        uint256 outputStart = encoded.length;
        uint256 inputStart = zeros;

        while (inputStart < inputCopy.length) {
            uint8 remainder = divmod(inputCopy, inputStart, 256, 58);
            outputStart--;
            encoded[outputStart] = bytes1(uint8(bytes(ALPHABET)[remainder]));
            if (inputCopy[inputStart] == 0) {
                inputStart++;
            }
        }

        // Preserve leading zeros
        while (
            outputStart < encoded.length &&
            encoded[outputStart] == bytes1(bytes(ALPHABET)[0])
        ) {
            outputStart++;
        }
        while (zeros > 0) {
            outputStart--;
            encoded[outputStart] = bytes1(bytes(ALPHABET)[0]);
            zeros--;
        }

        bytes memory result = new bytes(encoded.length - outputStart);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = encoded[outputStart + i];
        }
        return string(result);
    }

    function decode(string memory input) internal pure returns (bytes memory) {
        bytes memory inputBytes = bytes(input);
        if (inputBytes.length == 0) {
            return new bytes(0);
        }

        // Convert base58 string to base58 digits
        uint256[] memory input58 = new uint256[](inputBytes.length);
        for (uint256 i = 0; i < inputBytes.length; i++) {
            uint8 c = uint8(inputBytes[i]);
            uint256 digit = indexOf(c);
            require(digit >= 0, "Invalid character in Base58");
            input58[i] = digit;
        }

        // Count leading zeros
        uint256 zeros = 0;
        while (zeros < input58.length && input58[zeros] == 0) {
            zeros++;
        }

        // Convert base-58 digits to base-256 digits
        bytes memory decoded = new bytes(inputBytes.length);
        uint256 outputStart = decoded.length;

        for (uint256 inputStart = zeros; inputStart < input58.length; ) {
            outputStart--;
            decoded[outputStart] = bytes1(divmod(input58, inputStart, 58, 256));
            if (input58[inputStart] == 0) {
                inputStart++;
            }
        }

        // Ignore extra leading zeros
        while (outputStart < decoded.length && decoded[outputStart] == 0) {
            outputStart++;
        }

        return decoded;
    }

    function divmod(
        bytes memory number,
        uint256 firstDigit,
        uint256 base,
        uint256 divisor
    ) private pure returns (uint8) {
        uint256 remainder = 0;
        for (uint256 i = firstDigit; i < number.length; i++) {
            uint256 digit = uint8(number[i]);
            uint256 temp = remainder * base + digit;
            number[i] = bytes1(uint8(temp / divisor));
            remainder = temp % divisor;
        }
        return uint8(remainder);
    }

    function divmod(
        uint256[] memory number,
        uint256 firstDigit,
        uint256 base,
        uint256 divisor
    ) private pure returns (uint8) {
        uint256 remainder = 0;
        for (uint256 i = firstDigit; i < number.length; i++) {
            uint256 digit = number[i];
            uint256 temp = remainder * base + digit;
            number[i] = temp / divisor;
            remainder = temp % divisor;
        }
        return uint8(remainder);
    }

    function indexOf(uint8 char) private pure returns (uint8) {
        bytes memory alphabetBytes = bytes(ALPHABET);
        for (uint8 i = 0; i < alphabetBytes.length; i++) {
            if (alphabetBytes[i] == bytes1(char)) {
                return i;
            }
        }
        revert("Character not found in Base58 alphabet");
    }
}
