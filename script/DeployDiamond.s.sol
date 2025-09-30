// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
// IERC20 is already imported via IERC20Facet interface
import "../src/Diamond.sol";
import "../src/facets/DiamondCutFacet.sol";
import "../src/facets/DiamondLoupeFacet.sol";
import "../src/facets/ERC20Facet.sol";
import "../src/interfaces/IDiamondCut.sol";
import "../src/interfaces/IDiamondLoupe.sol";

/**
 * @title Deploy Diamond Script
 * @dev Deployment script for TrinNODE ERC20 Diamond contract
 * @notice Deploys diamond contract and adds all facets
 */
contract DeployDiamond is Script {
    function run() external {
        // Start broadcasting transactions using the configured account (compPrivate)
        // Deploy to Sepolia testnet
        vm.startBroadcast();

        // Step 1: Deploy all facets first
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        ERC20Facet erc20Facet = new ERC20Facet();

        console.log("DiamondCutFacet deployed at:", address(diamondCutFacet));
        console.log("DiamondLoupeFacet deployed at:", address(diamondLoupeFacet));
        console.log("ERC20Facet deployed at:", address(erc20Facet));

        // Step 2: Deploy the main Diamond contract
        Diamond diamond = new Diamond();
        console.log("Diamond deployed at:", address(diamond));

        // Step 3: Initialize the diamond with all facets using the initializeDiamond function
        diamond.initializeDiamond(
            address(diamondCutFacet),
            address(diamondLoupeFacet),
            address(erc20Facet)
        );

        console.log("All facets initialized in diamond");
        console.log("Diamond contract deployed at:", address(diamond));
        console.log("Deployer address:", msg.sender);

        // Stop broadcasting
        vm.stopBroadcast();
    }

    /// @notice Get function selectors for DiamondCutFacet
    function getDiamondCutSelectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = IDiamondCut.diamondCut.selector;
        return selectors;
    }

    /// @notice Get function selectors for DiamondLoupeFacet
    function getDiamondLoupeSelectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = IDiamondLoupe.facets.selector;
        selectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        selectors[2] = IDiamondLoupe.facetAddresses.selector;
        selectors[3] = IDiamondLoupe.facetAddress.selector;
        selectors[4] = IDiamondLoupe.supportsInterface.selector;
        return selectors;
    }

    /// @notice Get function selectors for ERC20Facet
    function getERC20Selectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors = new bytes4[](12);
        selectors[0] = bytes4(keccak256("name()"));
        selectors[1] = bytes4(keccak256("symbol()"));
        selectors[2] = bytes4(keccak256("decimals()"));
        selectors[3] = bytes4(keccak256("totalSupply()"));
        selectors[4] = bytes4(keccak256("balanceOf(address)"));
        selectors[5] = bytes4(keccak256("allowance(address,address)"));
        selectors[6] = bytes4(keccak256("approve(address,uint256)"));
        selectors[7] = bytes4(keccak256("transfer(address,uint256)"));
        selectors[8] = bytes4(keccak256("transferFrom(address,address,uint256)"));
        selectors[9] = IERC20Facet.mint.selector;
        selectors[10] = IERC20Facet.mintToSelf.selector;
        selectors[11] = IERC20Facet.batchMint.selector;
        return selectors;
    }
}
