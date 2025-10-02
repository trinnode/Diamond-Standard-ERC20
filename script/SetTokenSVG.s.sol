// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Diamond.sol";
import "../src/facets/ERC20MetadataFacet.sol";

/**
 * @title Set Token SVG Script
 * @dev Script to set the SVG image for the ERC20 token
 * @notice This script should be run after deploying the ERC20MetadataFacet
 */
contract SetTokenSVG is Script {
    function run() external {
        // Load the diamond address from environment
        address diamondAddress = 0xCD34f50b651374671C74781757d85faa75e5431e;

        // Load deployer private key
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast();

        // Get the ERC20MetadataFacet address (should be stored from previous deployment)
        address metadataFacet = 0xc8B5A34BC6791138d107E1348A24bB7c27C766e4;

                // Simple tNODE SVG with blue background
        string memory svgData = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjMzk4MERDIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1NSUiIGZvbnQtZmFtaWx5PSJBcmlhbCwgc2Fucy1zZXJpZiIgZm9udC1zaXplPSI0OCIgZm9udC13ZWlnaHQ9ImJvbGQiIGZpbGw9IndoaXRlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkeT0iLjNlbSI+dE5PREU8L3RleHQ+Cjwvc3ZnPg==";

        // Set the SVG data in the ERC20MetadataFacet
        ERC20MetadataFacet(metadataFacet).setTokenSVG(svgData);

        console.log("Token SVG set successfully");
        console.log("Diamond address:", diamondAddress);

        vm.stopBroadcast();
    }
}
