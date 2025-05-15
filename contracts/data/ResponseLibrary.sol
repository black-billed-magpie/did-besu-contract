// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library ResponseLibrary {
    struct Response {
        int32 status;
        string message;
        string payload;
    }

    int32 constant SUCCESS = 200;
    int32 constant ERROR = 400;
    int32 constant NOT_FOUND = 404;

    /// @notice Creates a new Response struct
    /// @param status The status code of the response
    /// @param message The message of the response
    /// @param payload The payload of the response
    /// @return A new Response struct
    function createResponse(
        int32 status,
        string memory message,
        string memory payload
    ) internal pure returns (Response memory) {
        return Response(status, message, payload);
    }
}
