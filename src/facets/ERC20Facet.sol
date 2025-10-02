// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "../interfaces/IERC20Facet.sol";

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../libraries/DiamondStorage.sol";

contract ERC20Facet is IERC20, IERC20Metadata {
    /// @notice Get token name
    function name() external view returns (string memory) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.name;
    }

    /// @notice Get token symbol
    function symbol() external view returns (string memory) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.symbol;
    }

    /// @notice Get number of decimals
    function decimals() external pure returns (uint8) {
        return 18;
    }

    /// @notice Get total supply
    function totalSupply() external view returns (uint256) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.totalSupply;
    }

    /// @notice Get balance of account
    /// @param account Account address
    function balanceOf(address account) external view returns (uint256) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.balanceOf[account];
    }

    /// @notice Get allowance for spender
    /// @param owner Token owner
    /// @param spender Spender address
    function allowance(address owner, address spender) external view returns (uint256) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.allowance[owner][spender];
    }

    /// @notice Approve spender to spend tokens
    /// @param spender Spender address
    /// @param amount Amount to approve
    function approve(address spender, uint256 amount) external returns (bool) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        ds.allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer tokens
    /// @param to Recipient address
    /// @param amount Amount to transfer
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Transfer tokens from approved address
    /// @param from Source address
    /// @param to Recipient address
    /// @param amount Amount to transfer
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(ds.allowance[from][msg.sender] >= amount, "Insufficient allowance");
        ds.allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }



    /// @notice Internal transfer function
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");

        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(ds.balanceOf[from] >= amount, "Insufficient balance");

        ds.balanceOf[from] -= amount;
        ds.balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }

    /// @notice Internal mint function
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Cannot mint to zero address");

        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        ds.totalSupply += amount;
        ds.balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    /// @notice Internal burn function (for completeness)
    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "Burn from zero address");

        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        require(ds.balanceOf[from] >= amount, "Insufficient balance");

        ds.balanceOf[from] -= amount;
        ds.totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }
}
