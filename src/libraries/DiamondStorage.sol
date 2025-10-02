// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Diamond Storage Library
 * @dev Library for managing diamond storage layout
 */
library DiamondStorage {
    struct DiamondState {
        // maps function selector to the facet address
        mapping(bytes4 => address) selectorToFacet;
        // maps facet address to function selectors
        mapping(address => bytes4[]) facetToSelectors;
        // facet addresses
        address[] facetAddresses;
        // ERC20 state variables
        string name;
        string symbol;
        uint256 totalSupply;
        mapping(address => uint256) balanceOf;
        mapping(address => mapping(address => uint256)) allowance;
        // owner of the diamond
        address contractOwner;
        // Swap functionality - ETH balances locked for tokens
        mapping(address => uint256) ethBalance;
        uint256 totalEthLocked;
        // MultiSig functionality
        mapping(bytes32 => bool) executedTransactions;
        mapping(bytes32 => uint256) transactionApprovals;
        mapping(bytes32 => mapping(address => bool)) hasApproved;
        address[] multiSigOwners;
        uint256 requiredApprovals;
        // ERC20Metadata - SVG token URI
        string tokenSVG;
    }

    // Storage position for the diamond state
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    /// @notice Get the diamond state from storage
    /// @return ds Diamond state
    function diamondStorage() internal pure returns (DiamondState storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
