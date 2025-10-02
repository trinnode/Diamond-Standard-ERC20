// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Diamond.sol";
import "../src/facets/SwapFacet.sol";
import "../src/facets/MultiSigFacet.sol";
import "../src/facets/ERC20MetadataFacet.sol";
import "../src/interfaces/IDiamondCut.sol";

/**
 * @title Deploy New Facets Script
 * @dev Deployment script for additional facets (Swap, MultiSig, ERC20Metadata)
 * @notice This script should be run after the main diamond deployment
 */
contract DeployNewFacets is Script {
    function run() external {
        // Load the diamond address from environment or use placeholder
        address diamondAddress = 0xCD34f50b651374671C74781757d85faa75e5431e;

        // Load deployer private key
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast();

        // Deploy new facets
        SwapFacet swapFacet = new SwapFacet();
        MultiSigFacet multiSigFacet = new MultiSigFacet();
        ERC20MetadataFacet erc20MetadataFacet = new ERC20MetadataFacet();

        console.log("SwapFacet deployed at:", address(swapFacet));
        console.log("MultiSigFacet deployed at:", address(multiSigFacet));
        console.log("ERC20MetadataFacet deployed at:", address(erc20MetadataFacet));

        // Get the diamond cut facet address (should be stored from previous deployment)
        address diamondCutFacet = 0xe6F30F30E8E434E32a3a9F175225D6A987ccEFA9;

        // Prepare diamond cut data to add new facets
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);

        // Add SwapFacet
        bytes4[] memory swapSelectors = new bytes4[](6);
        swapSelectors[0] = bytes4(keccak256("swapEthForTokens(uint256)"));
        swapSelectors[1] = bytes4(keccak256("swapTokensForEth(uint256)"));
        swapSelectors[2] = bytes4(keccak256("getEthBalance(address)"));
        swapSelectors[3] = bytes4(keccak256("getTotalEthLocked()"));
        swapSelectors[4] = bytes4(keccak256("getExchangeRate()"));
        swapSelectors[5] = bytes4(keccak256("setExchangeRate(uint256,uint256)"));

        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(swapFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: swapSelectors
        });

        // Add MultiSigFacet
        bytes4[] memory multiSigSelectors = new bytes4[](12);
        multiSigSelectors[0] = bytes4(keccak256("submitTransaction(address,uint256,bytes)"));
        multiSigSelectors[1] = bytes4(keccak256("approveTransaction(bytes32)"));
        multiSigSelectors[2] = bytes4(keccak256("revokeApproval(bytes32)"));
        multiSigSelectors[3] = bytes4(keccak256("executeTransaction(bytes32)"));
        multiSigSelectors[4] = bytes4(keccak256("getTransaction(bytes32)"));
        multiSigSelectors[5] = bytes4(keccak256("isOwner(address)"));
        multiSigSelectors[6] = bytes4(keccak256("getRequiredApprovals()"));
        multiSigSelectors[7] = bytes4(keccak256("getOwners()"));
        multiSigSelectors[8] = bytes4(keccak256("addOwner(address)"));
        multiSigSelectors[9] = bytes4(keccak256("removeOwner(address)"));
        multiSigSelectors[10] = bytes4(keccak256("changeRequiredApprovals(uint256)"));

        cuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(multiSigFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: multiSigSelectors
        });

        // Add ERC20MetadataFacet
        bytes4[] memory metadataSelectors = new bytes4[](3);
        metadataSelectors[0] = bytes4(keccak256("tokenURI()"));
        metadataSelectors[1] = bytes4(keccak256("setTokenSVG(string)"));
        metadataSelectors[2] = bytes4(keccak256("getTokenSVG()"));

        cuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(erc20MetadataFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: metadataSelectors
        });

        // Execute diamond cut
        IDiamondCut(diamondAddress).diamondCut(cuts, address(0), "");

        // Initialize multi-sig with deployer as first owner
        // Set required approvals to 1 for now (can be changed later)
        bytes memory initData = abi.encodeWithSignature(
            "initializeMultiSig(address[],uint256)",
            getInitialOwners(),
            1
        );

        // Call initializeMultiSig on the MultiSigFacet
        (bool success,) = address(multiSigFacet).call(initData);
        require(success, "MultiSig initialization failed");

        console.log("New facets added to diamond successfully");
        console.log("Diamond address:", diamondAddress);

        vm.stopBroadcast();
    }

    function getInitialOwners() internal view returns (address[] memory) {
        // For now, just use the deployer as the initial owner
        // In production, you might want multiple owners
        address[] memory owners = new address[](1);
        owners[0] = msg.sender;
        return owners;
    }
}
