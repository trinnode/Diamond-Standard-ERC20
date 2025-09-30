// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IDiamondLoupe.sol";
import "../libraries/DiamondStorage.sol";

/**
 * @title Diamond Loupe Facet
 * @dev Implementation of diamond introspection functionality
 */
contract DiamondLoupeFacet is IDiamondLoupe {
    /// @notice Gets all facet addresses and their four byte function selectors
    /// @return facets_ Array of facets
    function facets() external view override returns (Facet[] memory facets_) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();

        facets_ = new Facet[](ds.facetAddresses.length);
        for (uint256 i = 0; i < ds.facetAddresses.length; i++) {
            address currentFacetAddress = ds.facetAddresses[i];
            facets_[i] = Facet(currentFacetAddress, ds.facetToSelectors[currentFacetAddress]);
        }
    }

    /// @notice Gets all the function selectors supported by a specific facet
    /// @param _facet The facet address
    /// @return facetFunctionSelectors_ Array of function selectors
    function facetFunctionSelectors(address _facet) external view override returns (bytes4[] memory facetFunctionSelectors_) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        facetFunctionSelectors_ = ds.facetToSelectors[_facet];
    }

    /// @notice Get all the facet addresses used by a diamond
    /// @return facetAddresses_ Array of facet addresses
    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        facetAddresses_ = ds.facetAddresses;
    }

    /// @notice Gets the facet that supports the given selector
    /// @param _functionSelector The function selector
    /// @return facetAddress_ The facet address
    function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        facetAddress_ = ds.selectorToFacet[_functionSelector];
    }

    /// @notice Returns true if the diamond supports the given interface ID
    /// @param _interfaceId The interface ID
    /// @return supported_ True if supported
    function supportsInterface(bytes4 _interfaceId) external view override returns (bool supported_) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        supported_ = ds.selectorToFacet[_interfaceId] != address(0);
    }
}
