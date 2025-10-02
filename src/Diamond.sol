// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IDiamondCut.sol";
import "./interfaces/IDiamondLoupe.sol";
import "./libraries/DiamondStorage.sol";

/// @title TrinNODE Diamond Contract
/// @dev Main diamond contract that delegates function calls to facets tr
/// @notice ERC20 Diamond Standard implementation with open minting
contract Diamond {
    /// @notice Constructor initializes the diamond with initial facets
    constructor() {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        ds.contractOwner = msg.sender;

        // Initialize token metadata
        ds.name = "TrinNODE";
        ds.symbol = "tNODE";
        // ds.totalSupply = 100_000_000 * 10**18; // 100 million tokens with 18 decimals

        // Note: Facets will be added via diamondCut after deployment
        // This allows for proper facet management and upgradeability
    }

    /// @notice Fallback function that delegates calls to facets
    /// @dev This function is called when no other function matches
    fallback() external payable {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();

        // Get facet address from function selector
        address facet = ds.selectorToFacet[msg.sig];
        require(facet != address(0), "Function does not exist");

        // Execute external function call using delegatecall
        assembly {
            // Copy function call data
            calldatacopy(0, 0, calldatasize())

            // Execute delegatecall to facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)

            // Copy result data
            returndatacopy(0, 0, returndatasize())

            // Return or revert based on result
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /// @notice Receive function for handling plain ether transfers
    receive() external payable {}

    /// @notice Get contract owner
    function owner() external view returns (address) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.contractOwner;
    }

    /// @notice Transfer ownership (only owner can call)
    function transferOwnership(address _newOwner) external {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(msg.sender == ds.contractOwner, "Only owner can transfer ownership");
        require(_newOwner != address(0), "New owner cannot be zero address");
        ds.contractOwner = _newOwner;
    }

    /// @notice Initialize diamond with facets (only owner can call)
    /// @dev This function allows setting up facets after deployment
    function initializeDiamond(
        address _diamondCutFacet,
        address _diamondLoupeFacet,
        address _erc20Facet
    ) external {
        require(msg.sender == DiamondStorage.diamondStorage().contractOwner, "Only owner can initialize");

        // Manually add facets to storage
        bytes4[] memory diamondCutSelectors = new bytes4[](1);
        diamondCutSelectors[0] = bytes4(keccak256("diamondCut((address,uint8,bytes4[])[],address,bytes)"));

        bytes4[] memory diamondLoupeSelectors = new bytes4[](5);
        diamondLoupeSelectors[0] = bytes4(keccak256("facets()"));
        diamondLoupeSelectors[1] = bytes4(keccak256("facetFunctionSelectors(address)"));
        diamondLoupeSelectors[2] = bytes4(keccak256("facetAddresses()"));
        diamondLoupeSelectors[3] = bytes4(keccak256("facetAddress(bytes4)"));
        diamondLoupeSelectors[4] = bytes4(keccak256("supportsInterface(bytes4)"));

        bytes4[] memory erc20Selectors = new bytes4[](9);
        erc20Selectors[0] = bytes4(keccak256("name()"));
        erc20Selectors[1] = bytes4(keccak256("symbol()"));
        erc20Selectors[2] = bytes4(keccak256("decimals()"));
        erc20Selectors[3] = bytes4(keccak256("totalSupply()"));
        erc20Selectors[4] = bytes4(keccak256("balanceOf(address)"));
        erc20Selectors[5] = bytes4(keccak256("allowance(address,address)"));
        erc20Selectors[6] = bytes4(keccak256("approve(address,uint256)"));
        erc20Selectors[7] = bytes4(keccak256("transfer(address,uint256)"));
        erc20Selectors[8] = bytes4(keccak256("transferFrom(address,address,uint256)"));

        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();

        // Add DiamondCutFacet
        for (uint256 i = 0; i < diamondCutSelectors.length; i++) {
            ds.selectorToFacet[diamondCutSelectors[i]] = _diamondCutFacet;
        }
        ds.facetToSelectors[_diamondCutFacet] = diamondCutSelectors;
        ds.facetAddresses.push(_diamondCutFacet);

        // Add DiamondLoupeFacet
        for (uint256 i = 0; i < diamondLoupeSelectors.length; i++) {
            ds.selectorToFacet[diamondLoupeSelectors[i]] = _diamondLoupeFacet;
        }
        ds.facetToSelectors[_diamondLoupeFacet] = diamondLoupeSelectors;
        ds.facetAddresses.push(_diamondLoupeFacet);

        // Add ERC20Facet
        for (uint256 i = 0; i < erc20Selectors.length; i++) {
            ds.selectorToFacet[erc20Selectors[i]] = _erc20Facet;
        }
        ds.facetToSelectors[_erc20Facet] = erc20Selectors;
        ds.facetAddresses.push(_erc20Facet);
    }
}
