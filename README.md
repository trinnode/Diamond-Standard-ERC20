# 🚀 TrinNODE Diamond Contract Deployment Guide

This guide explains how to deploy and verify your upgraded TrinNODE Diamond contract with all the new features.

## 🎯 What's New in This Upgrade

- ✅ **Removed Open Minting** - No more unlimited token creation
- ✅ **ETH-Token Swap System** - Lock ETH to mint tokens, burn tokens to withdraw ETH
- ✅ **Multi-Signature Wallet** - Secure contract upgrades with multiple approvals
- ✅ **Onchain SVG Metadata** - Your tNODE.svg is embedded in the contract
- ✅ **Lisk Testnet Ready** - Optimized for Lisk Sepolia deployment

## 📋 Prerequisites

1. **Foundry** installed and configured
2. **Private Key** for deployment (with testnet ETH)
3. **Internet connection** for blockchain interactions

## 🚀 Quick Deployment (Automated)

### Step 1: Set Your Private Key
```bash
export PRIVATE_KEY=0x_your_private_key_here
```

### Step 2: Run the Automation Script
```bash
./deploy_and_verify.sh
```

That's it! The script will:
1. ✅ Deploy the main Diamond contract
2. ✅ Deploy and add new facets (Swap, MultiSig, ERC20Metadata)
3. ✅ Set your tNODE.svg as the token image
4. ✅ Update .env file with all addresses
5. ✅ Verify all contracts on Blockscout
6. ✅ Provide a complete summary

## 🔧 Manual Deployment (If Needed)

If you prefer to deploy step-by-step:

### Step 1: Deploy Main Diamond
```bash
forge script script/DeployDiamond.s.sol \
    --rpc-url https://rpc.sepolia-api.lisk.com \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Step 2: Deploy Additional Facets
```bash
export DIAMOND_ADDRESS=<from_step_1>
export DIAMOND_CUT_FACET_ADDRESS=<from_step_1>

forge script script/DeployNewFacets.s.sol \
    --rpc-url https://rpc.sepolia-api.lisk.com \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Step 3: Set Token SVG
```bash
export ERC20_METADATA_FACET_ADDRESS=<from_step_2>

forge script script/SetTokenSVG.s.sol \
    --rpc-url https://rpc.sepolia-api.lisk.com \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Step 4: Verify Contracts
```bash
# Update verifier.sh with your deployed addresses first
bash verifier.sh
```

## 🎨 Contract Features

### Swap Functionality
```solidity
// Swap ETH for tokens (1 ETH = 1000 tokens)
diamond.swapEthForTokens(tokenAmount, {value: ethAmount});

// Swap tokens for ETH
diamond.swapTokensForEth(tokenAmount);
```

### Multi-Signature Governance
```solidity
// Submit a contract upgrade for approval
diamond.submitTransaction(targetAddress, value, data);

// Approve the transaction
diamond.approveTransaction(transactionId);

// Execute after required approvals
diamond.executeTransaction(transactionId);
```

### Token Metadata
```solidity
// Get token URI with embedded SVG
string memory metadata = diamond.tokenURI();

// Get just the SVG
string memory svg = diamond.getTokenSVG();
```

## 🔍 Verification

Your contracts will be verified on:
- **Blockscout Explorer**: https://sepolia-blockscout.lisk.com
- **Network**: Lisk Sepolia Testnet (Chain ID: 4202)

## 📄 Environment Variables

After deployment, your `.env` file will contain:
```
DIAMOND_ADDRESS=0x...
DIAMOND_CUT_FACET_ADDRESS=0x...
DIAMOND_LOUPE_FACET_ADDRESS=0x...
ERC20_FACET_ADDRESS=0x...
SWAP_FACET_ADDRESS=0x...
MULTISIG_FACET_ADDRESS=0x...
ERC20_METADATA_FACET_ADDRESS=0x...
```

## 🛠️ Troubleshooting

### Common Issues:

1. **Out of Gas**: Try reducing the batch size or increase gas limit
2. **Verification Failed**: Check that all constructor arguments are correct
3. **Network Issues**: Verify you're connected to the correct RPC

### Getting Help:
- Check the deployment logs in the terminal output
- Verify your private key has sufficient testnet ETH
- Ensure Foundry is properly installed and configured

## 🎉 What You Get

- **🔒 Secure**: Multi-signature controlled upgrades
- **💰 Backed**: Every token backed by locked ETH
- **🎨 Visual**: Onchain SVG visible on explorers
- **⚡ Efficient**: Diamond pattern for gas optimization
- **🔄 Upgradeable**: Add new features without migration

## 📞 Support

If you encounter any issues:
1. Check the error messages in the terminal
2. Verify your private key and network connection
3. Ensure all dependencies are installed
4. Check gas limits and balances

---

**Happy Deploying! 🚀**

Your TrinNODE Diamond contract is now ready with enterprise-grade features including ETH-backed tokens, multi-signature governance, and beautiful onchain SVG metadata!
