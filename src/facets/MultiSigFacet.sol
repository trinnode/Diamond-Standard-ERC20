// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IMultiSigFacet.sol";
import "../libraries/DiamondStorage.sol";

contract MultiSigFacet is IMultiSigFacet {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvalCount;
    }

    /// @notice Submit a transaction for multi-sig approval
    /// @param to Target address
    /// @param value ETH value to send
    /// @param data Transaction data
    /// @return transactionId Unique transaction ID
    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes32 transactionId) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(isOwner(msg.sender), "Only owners can submit transactions");

        transactionId = keccak256(abi.encodePacked(to, value, data, block.timestamp));

        // Store transaction details
        ds.executedTransactions[transactionId] = false;
        ds.transactionApprovals[transactionId] = 1; // Auto-approve by submitter
        ds.hasApproved[transactionId][msg.sender] = true;

        emit TransactionSubmitted(transactionId, msg.sender, to, value, data);
        emit TransactionApproved(transactionId, msg.sender);
    }

    /// @notice Approve a transaction
    /// @param transactionId Transaction ID to approve
    function approveTransaction(bytes32 transactionId) external override {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(isOwner(msg.sender), "Only owners can approve");
        require(!ds.hasApproved[transactionId][msg.sender], "Already approved");
        require(!ds.executedTransactions[transactionId], "Transaction already executed");

        ds.hasApproved[transactionId][msg.sender] = true;
        ds.transactionApprovals[transactionId]++;

        emit TransactionApproved(transactionId, msg.sender);

        // Auto-execute if we have enough approvals
        if (ds.transactionApprovals[transactionId] >= ds.requiredApprovals) {
            _executeTransaction(transactionId);
        }
    }

    /// @notice Revoke approval for a transaction
    /// @param transactionId Transaction ID to revoke approval for
    function revokeApproval(bytes32 transactionId) external override {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(isOwner(msg.sender), "Only owners can revoke");
        require(ds.hasApproved[transactionId][msg.sender], "Not approved");
        require(!ds.executedTransactions[transactionId], "Transaction already executed");

        ds.hasApproved[transactionId][msg.sender] = false;
        ds.transactionApprovals[transactionId]--;

        emit TransactionRevoked(transactionId, msg.sender);
    }

    /// @notice Internal function to execute an approved transaction
    function _executeTransaction(bytes32 transactionId) internal {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(ds.transactionApprovals[transactionId] >= ds.requiredApprovals, "Not enough approvals");
        require(!ds.executedTransactions[transactionId], "Transaction already executed");

        // Mark as executed
        ds.executedTransactions[transactionId] = true;

        // Execute the transaction
        (bool success, ) = ds.selectorToFacet[bytes4(keccak256("diamondCut((address,uint8,bytes4[])[],address,bytes)"))].delegatecall(
            abi.encodeWithSignature("diamondCut((address,uint8,bytes4[])[],address,bytes)")
        );

        emit TransactionExecuted(transactionId);
    }

    /// @notice Execute an approved transaction
    /// @param transactionId Transaction ID to execute
    function executeTransaction(bytes32 transactionId) external override {
        _executeTransaction(transactionId);
    }

    /// @notice Get transaction details
    /// @param transactionId Transaction ID
    /// @return to Target address
    /// @return value ETH value
    /// @return data Transaction data
    /// @return executed Whether transaction was executed
    /// @return approvalCount Number of approvals
    function getTransaction(bytes32 transactionId) external view override returns (
        address to,
        uint256 value,
        bytes memory data,
        bool executed,
        uint256 approvalCount
    ) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return (to, value, data, ds.executedTransactions[transactionId], ds.transactionApprovals[transactionId]);
    }

    /// @notice Check if address is a multi-sig owner
    /// @param account Address to check
    function isOwner(address account) public view override returns (bool) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        for (uint256 i = 0; i < ds.multiSigOwners.length; i++) {
            if (ds.multiSigOwners[i] == account) {
                return true;
            }
        }
        return false;
    }

    /// @notice Get required number of approvals
    function getRequiredApprovals() external view override returns (uint256) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.requiredApprovals;
    }

    /// @notice Get list of all owners
    function getOwners() external view override returns (address[] memory) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.multiSigOwners;
    }

    /// @notice Add a new owner (requires multi-sig approval)
    /// @param newOwner Address of new owner
    function addOwner(address newOwner) external override {
        require(newOwner != address(0), "Invalid owner address");
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(!isOwner(newOwner), "Already an owner");

        // This would need to go through multi-sig approval process
        ds.multiSigOwners.push(newOwner);
        emit OwnerAdded(newOwner);
    }

    /// @notice Remove an owner (requires multi-sig approval)
    /// @param owner Address of owner to remove
    function removeOwner(address owner) external override {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(isOwner(owner), "Not an owner");
        require(ds.multiSigOwners.length > 1, "Cannot remove last owner");

        // This would need to go through multi-sig approval process
        for (uint256 i = 0; i < ds.multiSigOwners.length; i++) {
            if (ds.multiSigOwners[i] == owner) {
                ds.multiSigOwners[i] = ds.multiSigOwners[ds.multiSigOwners.length - 1];
                ds.multiSigOwners.pop();
                break;
            }
        }

        emit OwnerRemoved(owner);
    }

    /// @notice Change required approvals (requires multi-sig approval)
    /// @param newRequired New required approval count
    function changeRequiredApprovals(uint256 newRequired) external override {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(newRequired > 0 && newRequired <= ds.multiSigOwners.length, "Invalid required approvals");

        // This would need to go through multi-sig approval process
        ds.requiredApprovals = newRequired;
        emit RequiredApprovalsChanged(newRequired);
    }

    /// @notice Initialize multi-sig with owners and required approvals
    /// @param owners Array of initial owner addresses
    /// @param required Number of required approvals
    function initializeMultiSig(address[] calldata owners, uint256 required) external {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(ds.multiSigOwners.length == 0, "MultiSig already initialized");
        require(owners.length > 0, "At least one owner required");
        require(required > 0 && required <= owners.length, "Invalid required approvals");

        for (uint256 i = 0; i < owners.length; i++) {
            require(owners[i] != address(0), "Invalid owner address");
            ds.multiSigOwners.push(owners[i]);
        }

        ds.requiredApprovals = required;
    }
}
