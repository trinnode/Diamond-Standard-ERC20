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
