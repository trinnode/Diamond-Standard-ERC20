// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IMultiSigFacet {
    /// @notice Submit a transaction for multi-sig approval
    /// @param to Target address
    /// @param value ETH value to send
    /// @param data Transaction data
    /// @return transactionId Unique transaction ID
    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bytes32 transactionId);

    /// @notice Approve a transaction
    /// @param transactionId Transaction ID to approve
    function approveTransaction(bytes32 transactionId) external;

    /// @notice Revoke approval for a transaction
    /// @param transactionId Transaction ID to revoke approval for
    function revokeApproval(bytes32 transactionId) external;

    /// @notice Execute an approved transaction
    /// @param transactionId Transaction ID to execute
    function executeTransaction(bytes32 transactionId) external;

    /// @notice Get transaction details
    /// @param transactionId Transaction ID
    /// @return to Target address
    /// @return value ETH value
    /// @return data Transaction data
    /// @return executed Whether transaction was executed
    /// @return approvalCount Number of approvals
    function getTransaction(bytes32 transactionId) external view returns (
        address to,
        uint256 value,
        bytes memory data,
        bool executed,
        uint256 approvalCount
    );

    /// @notice Check if address is a multi-sig owner
    /// @param account Address to check
    function isOwner(address account) external view returns (bool);

    /// @notice Get required number of approvals
    function getRequiredApprovals() external view returns (uint256);

    /// @notice Get list of all owners
    function getOwners() external view returns (address[] memory);

    /// @notice Add a new owner (requires multi-sig approval)
    /// @param newOwner Address of new owner
    function addOwner(address newOwner) external;

    /// @notice Remove an owner (requires multi-sig approval)
    /// @param owner Address of owner to remove
    function removeOwner(address owner) external;

    /// @notice Change required approvals (requires multi-sig approval)
    /// @param newRequired New required approval count
    function changeRequiredApprovals(uint256 newRequired) external;

    /// @notice Events
    event TransactionSubmitted(bytes32 indexed transactionId, address indexed owner, address to, uint256 value, bytes data);
    event TransactionApproved(bytes32 indexed transactionId, address indexed owner);
    event TransactionRevoked(bytes32 indexed transactionId, address indexed owner);
    event TransactionExecuted(bytes32 indexed transactionId);
    event OwnerAdded(address indexed owner);
    event OwnerRemoved(address indexed owner);
    event RequiredApprovalsChanged(uint256 newRequired);
}
