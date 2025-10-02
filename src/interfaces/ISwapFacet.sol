// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISwapFacet {
    /// @notice Swap ETH for tokens - locks ETH and mints equivalent tokens
    /// @param tokenAmount Amount of tokens to receive
    function swapEthForTokens(uint256 tokenAmount) external payable;

    /// @notice Swap tokens for ETH - burns tokens and releases ETH
    /// @param tokenAmount Amount of tokens to burn
    function swapTokensForEth(uint256 tokenAmount) external;

    /// @notice Get ETH balance for an address
    /// @param account Account address
    function getEthBalance(address account) external view returns (uint256);

    /// @notice Get total ETH locked in the contract
    function getTotalEthLocked() external view returns (uint256);

    /// @notice Get current ETH to token exchange rate
    function getExchangeRate() external view returns (uint256 ethAmount, uint256 tokenAmount);

    /// @notice Set exchange rate (only multi-sig can call)
    /// @param ethAmount Amount of ETH
    /// @param tokenAmount Equivalent amount of tokens
    function setExchangeRate(uint256 ethAmount, uint256 tokenAmount) external;

    /// @notice Events
    event TokensSwapped(address indexed user, uint256 ethAmount, uint256 tokenAmount, bool isEthToToken);
    event ExchangeRateUpdated(uint256 ethAmount, uint256 tokenAmount);
}
