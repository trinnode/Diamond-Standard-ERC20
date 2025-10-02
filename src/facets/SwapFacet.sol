// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/ISwapFacet.sol";
import "../interfaces/IERC20Facet.sol";
import "../libraries/DiamondStorage.sol";

contract SwapFacet is ISwapFacet {
    // Exchange rate: 1 ETH = 1000 tokens (customizable)
    uint256 private constant DEFAULT_ETH_AMOUNT = 1 ether;
    uint256 private constant DEFAULT_TOKEN_AMOUNT = 1000 * 10**18;

    /// @notice Swap ETH for tokens - locks ETH and mints equivalent tokens
    /// @param tokenAmount Amount of tokens to receive
    function swapEthForTokens(uint256 tokenAmount) external payable override {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        require(msg.value > 0, "ETH amount must be greater than 0");

        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();

        // Calculate required ETH based on exchange rate
        (uint256 ethRate, uint256 tokenRate) = getExchangeRate();
        uint256 requiredEth = (tokenAmount * ethRate) / tokenRate;

        require(msg.value >= requiredEth, "Insufficient ETH sent");

        // Lock the ETH
        ds.ethBalance[msg.sender] += msg.value;
        ds.totalEthLocked += msg.value;

        // Mint tokens to user (using ERC20Facet functions)
        address erc20Facet = ds.selectorToFacet[bytes4(keccak256("mint(address,uint256)"))];
        require(erc20Facet != address(0), "ERC20Facet not found");

        // Call mint function on ERC20Facet using delegatecall
        (bool success,) = erc20Facet.delegatecall(
            abi.encodeWithSignature("mint(address,uint256)", msg.sender, tokenAmount)
        );
        require(success, "Token minting failed");

        // Refund excess ETH if any
        if (msg.value > requiredEth) {
            payable(msg.sender).transfer(msg.value - requiredEth);
            ds.ethBalance[msg.sender] -= (msg.value - requiredEth);
            ds.totalEthLocked -= (msg.value - requiredEth);
        }

        emit TokensSwapped(msg.sender, msg.value, tokenAmount, true);
    }

    /// @notice Swap tokens for ETH - burns tokens and releases ETH
    /// @param tokenAmount Amount of tokens to burn
    function swapTokensForEth(uint256 tokenAmount) external override {
        require(tokenAmount > 0, "Token amount must be greater than 0");

        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();

        // Check if user has enough ETH locked
        (uint256 ethRate, uint256 tokenRate) = getExchangeRate();
        uint256 ethToRelease = (tokenAmount * ethRate) / tokenRate;

        require(ds.ethBalance[msg.sender] >= ethToRelease, "Insufficient ETH balance");

        // Burn tokens first (using ERC20Facet functions)
        address erc20Facet = ds.selectorToFacet[bytes4(keccak256("transferFrom(address,address,uint256)"))];
        require(erc20Facet != address(0), "ERC20Facet not found");

        // Call transferFrom to burn tokens (transfer to address(0))
        (bool success,) = erc20Facet.delegatecall(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(0), tokenAmount)
        );
        require(success, "Token burning failed");

        // Release ETH to user
        ds.ethBalance[msg.sender] -= ethToRelease;
        ds.totalEthLocked -= ethToRelease;

        payable(msg.sender).transfer(ethToRelease);

        emit TokensSwapped(msg.sender, ethToRelease, tokenAmount, false);
    }

    /// @notice Get ETH balance for an address
    /// @param account Account address
    function getEthBalance(address account) external view override returns (uint256) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.ethBalance[account];
    }

    /// @notice Get total ETH locked in the contract
    function getTotalEthLocked() external view override returns (uint256) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.totalEthLocked;
    }

    /// @notice Get current ETH to token exchange rate
    function getExchangeRate() public pure override returns (uint256 ethAmount, uint256 tokenAmount) {
        return (DEFAULT_ETH_AMOUNT, DEFAULT_TOKEN_AMOUNT);
    }

    /// @notice Set exchange rate (only multi-sig can call)
    /// @param ethAmount Amount of ETH
    /// @param tokenAmount Equivalent amount of tokens
    function setExchangeRate(uint256 ethAmount, uint256 tokenAmount) external override {
        // This will be restricted to multi-sig owners once MultiSigFacet is implemented
        require(ethAmount > 0 && tokenAmount > 0, "Invalid exchange rate");
        emit ExchangeRateUpdated(ethAmount, tokenAmount);
    }
}
