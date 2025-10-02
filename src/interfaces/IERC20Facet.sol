// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/**
 * @title ERC20 Facet Interface
 * @dev Interface for ERC20 functionality in the diamond
 */
interface IERC20Facet is IERC20 {
    /// @notice Mint tokens to specified address (anyone can call)
    /// @param to Address to mint tokens to
    /// @param amount Amount of tokens to mint
    // function mint(address to, uint256 amount) external;

    /// @notice Mint tokens to caller's address (anyone can call)
    /// @param amount Amount of tokens to mint
    // function mintToSelf(uint256 amount) external;

    /// @notice Batch mint tokens to multiple addresses (anyone can call)
    /// @param recipients Array of addresses to mint to
    /// @param amounts Array of amounts to mint (must match recipients length)
    // function batchMint(address[] calldata recipients, uint256[] calldata amounts) external;
}
