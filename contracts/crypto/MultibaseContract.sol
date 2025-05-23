// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultibaseContract {
    event MultibaseContractSetup();

    string internal constant BASE58_ALPHABET =
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    // Base64 encoding/decoding alphabet
    string internal constant BASE64_ALPHABET =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    string internal constant BASE58_PREFIX = "z";
    string internal constant BASE64_PREFIX = "m";

    constructor() {
        emit MultibaseContractSetup();
    }

    // Multibase 인코딩
    function encodeMultibase(
        bytes memory input,
        string memory base
    ) external pure returns (string memory) {
        if (keccak256(bytes(base)) == keccak256(bytes("base58"))) {
            return string(abi.encodePacked(BASE58_PREFIX, encodeBase58(input)));
        } else if (keccak256(bytes(base)) == keccak256(bytes("base64"))) {
            return string(abi.encodePacked(BASE64_PREFIX, encodeBase64(input)));
        } else {
            revert("Unsupported base");
        }
    }

    // Multibase 디코딩
    function decodeMultibase(
        string memory input
    ) external pure returns (bytes memory) {
        bytes memory inputBytes = bytes(input);
        require(inputBytes.length > 1, "Input too short");
        bytes1 prefix = inputBytes[0];
        if (prefix == bytes1(bytes(BASE58_PREFIX))) {
            // base58 디코딩
            string memory payload = substring(input, 1, inputBytes.length);
            return decodeBase58(payload);
        } else if (prefix == bytes1(bytes(BASE64_PREFIX))) {
            // base64 디코딩
            string memory payload = substring(input, 1, inputBytes.length);
            return decodeBase64(payload);
        } else {
            revert("Unsupported multibase prefix");
        }
    }

    function encodeBase58(
        bytes memory input
    ) internal pure returns (string memory) {
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
            encoded[outputStart] = bytes1(
                uint8(bytes(BASE58_ALPHABET)[remainder])
            );
            if (inputCopy[inputStart] == 0) {
                inputStart++;
            }
        }

        // Preserve leading zeros
        while (
            outputStart < encoded.length &&
            encoded[outputStart] == bytes1(bytes(BASE58_ALPHABET)[0])
        ) {
            outputStart++;
        }
        while (zeros > 0) {
            outputStart--;
            encoded[outputStart] = bytes1(bytes(BASE58_ALPHABET)[0]);
            zeros--;
        }

        bytes memory result = new bytes(encoded.length - outputStart);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = encoded[outputStart + i];
        }
        return string(result);
    }

    function decodeBase58(
        string memory input
    ) internal pure returns (bytes memory) {
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

    function encodeBase64(
        bytes memory data
    ) internal pure returns (string memory) {
        if (data.length == 0) return "";
        string memory table = BASE64_ALPHABET;
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        string memory result = new string(encodedLen);
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for {
                let i := 0
            } lt(i, mload(data)) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(18, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(12, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(6, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }
        return result;
    }

    function decodeBase64(
        string memory _data
    ) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);
        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "Invalid Base64 input");
        string
            memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        bytes memory tableBytes = bytes(table);
        uint256 decodedLen = (data.length / 4) * 3;
        if (data[data.length - 1] == "=") decodedLen--;
        if (data[data.length - 2] == "=") decodedLen--;
        bytes memory result = new bytes(decodedLen);
        uint256[256] memory decodeMap;
        for (uint256 i = 0; i < 64; i++) {
            decodeMap[uint8(tableBytes[i])] = i;
        }
        for (uint256 i = 0; i < data.length; i += 4) {
            uint256 a = decodeMap[uint8(data[i])];
            uint256 b = decodeMap[uint8(data[i + 1])];
            uint256 c = decodeMap[uint8(data[i + 2])];
            uint256 d = decodeMap[uint8(data[i + 3])];
            uint256 chunk = (a << 18) | (b << 12) | (c << 6) | d;
            uint256 j = (i / 4) * 3;
            if (j < result.length) result[j] = bytes1(uint8(chunk >> 16));
            if (j + 1 < result.length)
                result[j + 1] = bytes1(uint8(chunk >> 8));
            if (j + 2 < result.length) result[j + 2] = bytes1(uint8(chunk));
        }
        return result;
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
        bytes memory alphabetBytes = bytes(BASE58_ALPHABET);
        for (uint8 i = 0; i < alphabetBytes.length; i++) {
            if (alphabetBytes[i] == bytes1(char)) {
                return i;
            }
        }
        revert("Character not found in Base58 alphabet");
    }

    function substring(
        string memory str,
        uint startIndex,
        uint endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}
