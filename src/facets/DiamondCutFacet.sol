// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IDiamondCut.sol";
import "../libraries/DiamondStorage.sol";

/**
 * @title Diamond Cut Facet
 * @dev Implementation of diamond cut functionality
 */
contract DiamondCutFacet is IDiamondCut {
    /// @notice Add/replace/remove any number of functions and optionally execute a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments to execute with delegatecall
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(msg.sender == ds.contractOwner, "Only contract owner can cut facets");

        for (uint256 i = 0; i < _diamondCut.length; i++) {
            FacetCut memory facetCut = _diamondCut[i];
            if (facetCut.action == FacetCutAction.Add) {
                addFacet(ds, facetCut.facetAddress, facetCut.functionSelectors);
            } else if (facetCut.action == FacetCutAction.Replace) {
                replaceFacet(ds, facetCut.facetAddress, facetCut.functionSelectors);
            } else if (facetCut.action == FacetCutAction.Remove) {
                removeFacet(ds, facetCut.facetAddress, facetCut.functionSelectors);
            }
        }

        emit DiamondCut(_diamondCut, _init, _calldata);

        if (_init != address(0)) {
            (bool success,) = _init.delegatecall(_calldata);
            require(success, "Initialization function failed");
        }
    }

    /// @notice Internal function to add a facet
    function addFacet(
        DiamondStorage.DiamondState storage ds,
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        require(_facetAddress != address(0), "Facet address cannot be zero");
        require(ds.facetToSelectors[_facetAddress].length == 0, "Facet already exists");

        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            require(ds.selectorToFacet[_functionSelectors[i]] == address(0), "Function selector already exists");
            ds.selectorToFacet[_functionSelectors[i]] = _facetAddress;
        }

        ds.facetToSelectors[_facetAddress] = _functionSelectors;
        ds.facetAddresses.push(_facetAddress);
    }

    /// @notice Internal function to replace a facet
    function replaceFacet(
        DiamondStorage.DiamondState storage ds,
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        require(_facetAddress != address(0), "Facet address cannot be zero");
        require(ds.facetToSelectors[_facetAddress].length != 0, "Facet does not exist");

        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            address oldFacetAddress = ds.selectorToFacet[_functionSelectors[i]];
            require(oldFacetAddress != address(0), "Function selector does not exist");
            ds.selectorToFacet[_functionSelectors[i]] = _facetAddress;
        }
    }

    /// @notice Internal function to remove a facet
    function removeFacet(
        DiamondStorage.DiamondState storage ds,
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        require(_facetAddress == address(0), "Remove facet address must be zero");
        require(ds.facetToSelectors[_facetAddress].length != 0, "Facet does not exist");

        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            address oldFacetAddress = ds.selectorToFacet[_functionSelectors[i]];
            require(oldFacetAddress != address(0), "Function selector does not exist");
            delete ds.selectorToFacet[_functionSelectors[i]];
        }

        // Remove facet from facetAddresses array
        for (uint256 i = 0; i < ds.facetAddresses.length; i++) {
            if (ds.facetAddresses[i] == _facetAddress) {
                ds.facetAddresses[i] = ds.facetAddresses[ds.facetAddresses.length - 1];
                ds.facetAddresses.pop();
                break;
            }
        }

        delete ds.facetToSelectors[_facetAddress];
    }
}
