// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title RoleLibrary
 * @dev Library for defining role constants used in access control throughout the DID/VC system.
 *      Each role is represented as a unique bytes32 identifier using keccak256 hashing.
 */
library RoleLibrary {
    /// @notice Administrator role for contract management
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    /// @notice TAS (Trusted Application Service) role
    bytes32 public constant TAS = keccak256("Tas");
    /// @notice Wallet role
    bytes32 public constant WALLET = keccak256("Wallet");
    /// @notice Issuer role for credential issuance
    bytes32 public constant ISSUER = keccak256("Issuer");
    /// @notice Verifier role for credential verification
    bytes32 public constant VERIFIER = keccak256("Verifier");
    /// @notice Wallet provider role
    bytes32 public constant WALLET_PROVIDER = keccak256("WalletProvider");
    /// @notice App provider role
    bytes32 public constant APP_PROVIDER = keccak256("AppProvider");
    /// @notice List provider role
    bytes32 public constant LIST_PROVIDER = keccak256("ListProvider");
    /// @notice Operation provider role
    bytes32 public constant OP_PROVIDER = keccak256("OpProvider");
    /// @notice KYC provider role
    bytes32 public constant KYC_PROVIDER = keccak256("KycProvider");
    /// @notice Notification provider role
    bytes32 public constant NOTIFICATION_PROVIDER =
        keccak256("NotificationProvider");
    /// @notice Log provider role
    bytes32 public constant LOG_PROVIDER = keccak256("LogProvider");
    /// @notice Portal provider role
    bytes32 public constant PORTAL_PROVIDER = keccak256("PortalProvider");
    /// @notice Delegation provider role
    bytes32 public constant DELEGATION_PROVIDER =
        keccak256("DelegationProvider");
    /// @notice Storage provider role
    bytes32 public constant STORAGE_PROVIDER = keccak256("StorageProvider");
    /// @notice Backup provider role
    bytes32 public constant BACKUP_PROVIDER = keccak256("BackupProvider");
    /// @notice ETC (miscellaneous) role
    bytes32 public constant ETC = keccak256("Etc");
}
