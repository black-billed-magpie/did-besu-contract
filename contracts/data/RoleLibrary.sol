// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library RoleLibrary {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant TAS = keccak256("Tas");
    bytes32 public constant WALLET = keccak256("Wallet");
    bytes32 public constant ISSUER = keccak256("Issuer");
    bytes32 public constant VERIFIER = keccak256("Verifier");
    bytes32 public constant WALLET_PROVIDER = keccak256("WalletProvider");
    bytes32 public constant APP_PROVIDER = keccak256("AppProvider");
    bytes32 public constant LIST_PROVIDER = keccak256("ListProvider");
    bytes32 public constant OP_PROVIDER = keccak256("OpProvider");
    bytes32 public constant KYC_PROVIDER = keccak256("KycProvider");
    bytes32 public constant NOTIFICATION_PROVIDER =
        keccak256("NotificationProvider");
    bytes32 public constant LOG_PROVIDER = keccak256("LogProvider");
    bytes32 public constant PORTAL_PROVIDER = keccak256("PortalProvider");
    bytes32 public constant DELEGATION_PROVIDER =
        keccak256("DelegationProvider");
    bytes32 public constant STORAGE_PROVIDER = keccak256("StorageProvider");
    bytes32 public constant BACKUP_PROVIDER = keccak256("BackupProvider");
    bytes32 public constant ETC = keccak256("Etc");
}
