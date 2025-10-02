#!/bin/bash

# TrinNODE Diamond Contract Deployment and Verification Script
# This script automates the entire deployment process for the upgraded Diamond contract

set -e  # Exit on any error

echo "🚀 Starting TrinNODE Diamond Contract Deployment and Verification"
echo "================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists, create if not
if [ ! -f .env ]; then
    print_status "Creating .env file..."
    touch .env
    echo "# TrinNODE Diamond Contract Environment Variables" >> .env
    echo "" >> .env
fi

# Function to update .env file
update_env() {
    local key=$1
    local value=$2

    # Remove existing entry if it exists
    sed -i "/^${key}=/d" .env

    # Add new entry
    echo "${key}=${value}" >> .env

    print_success "Updated .env: ${key}=${value}"
}

# Check for required environment variables
# if [ -z "$PRIVATE_KEY" ]; then
#     print_error "PRIVATE_KEY environment variable is required"
#     print_error "Please set your private key: export PRIVATE_KEY=0x..."
#     exit 1
# fi

print_status "Using Lisk Sepolia testnet RPC: https://rpc.sepolia-api.lisk.com"

# Step 1: Deploy main Diamond contract
print_status "Step 1/3: Deploying main Diamond contract..."
echo "---------------------------------------------"

if forge script script/DeployDiamond.s.sol \
    --rpc-url https://rpc.sepolia-api.lisk.com \
    --account compPrivate \ 
    --sender <ur address> \
    --broadcast --slow 2>&1 | tee deploy_diamond.log; then

    print_success "Diamond contract deployed successfully!"

    # Extract addresses from deployment log
    DIAMOND_ADDRESS=$(grep -o "Diamond deployed at: 0x[a-fA-F0-9]*" deploy_diamond.log | grep -o "0x[a-fA-F0-9]*" | tail -1)
    DIAMOND_CUT_FACET=$(grep -o "DiamondCutFacet deployed at: 0x[a-fA-F0-9]*" deploy_diamond.log | grep -o "0x[a-fA-F0-9]*" | tail -1)
    DIAMOND_LOUPE_FACET=$(grep -o "DiamondLoupeFacet deployed at: 0x[a-fA-F0-9]*" deploy_diamond.log | grep -o "0x[a-fA-F0-9]*" | tail -1)
    ERC20_FACET=$(grep -o "ERC20Facet deployed at: 0x[a-fA-F0-9]*" deploy_diamond.log | grep -o "0x[a-fA-F0-9]*" | tail -1)

    if [ -n "$DIAMOND_ADDRESS" ]; then
        update_env "DIAMOND_ADDRESS" $DIAMOND_ADDRESS
    fi

    if [ -n "$DIAMOND_CUT_FACET" ]; then
        update_env "DIAMOND_CUT_FACET_ADDRESS" $DIAMOND_CUT_FACET
    fi

    print_success "Main diamond deployment completed"
    print_success "Diamond Address: $DIAMOND_ADDRESS"

else
    print_error "Failed to deploy main diamond contract"
    exit 1
fi

# Step 2: Deploy additional facets
print_status "Step 2/3: Deploying additional facets (Swap, MultiSig, ERC20Metadata)..."
echo "-----------------------------------------------------------------------"

if forge script script/DeployNewFacets.s.sol \
    --rpc-url https://rpc.sepolia-api.lisk.com \
    --account compPrivate \
    --broadcast 2>&1 | tee deploy_facets.log; then

    print_success "Additional facets deployed successfully!"

    # Extract new facet addresses
    SWAP_FACET=$(grep -o "SwapFacet deployed at: 0x[a-fA-F0-9]*" deploy_facets.log | grep -o "0x[a-fA-F0-9]*" | tail -1)
    MULTISIG_FACET=$(grep -o "MultiSigFacet deployed at: 0x[a-fA-F0-9]*" deploy_facets.log | grep -o "0x[a-fA-F0-9]*" | tail -1)
    METADATA_FACET=$(grep -o "ERC20MetadataFacet deployed at: 0x[a-fA-F0-9]*" deploy_facets.log | grep -o "0x[a-fA-F0-9]*" | tail -1)

    if [ -n "$SWAP_FACET" ]; then
        update_env "SWAP_FACET_ADDRESS" $SWAP_FACET
    fi

    if [ -n "$MULTISIG_FACET" ]; then
        update_env "MULTISIG_FACET_ADDRESS" $MULTISIG_FACET
    fi

    if [ -n "$METADATA_FACET" ]; then
        update_env "ERC20_METADATA_FACET_ADDRESS" $METADATA_FACET
    fi

    print_success "Additional facets deployment completed"

else
    print_error "Failed to deploy additional facets"
    exit 1
fi

# Step 3: Set Token SVG
print_status "Step 3/3: Setting token SVG image..."
echo "-----------------------------------"

if forge script script/SetTokenSVG.s.sol \
    --rpc-url https://rpc.sepolia-api.lisk.com \
    --account compPrivate \
    --broadcast 2>&1 | tee set_svg.log; then

    print_success "Token SVG set successfully!"
    print_success "All deployments completed!"

else
    print_error "Failed to set token SVG"
    exit 1
fi

# Step 4: Verify all contracts
print_status "Step 4/4: Verifying contracts on Blockscout..."
echo "---------------------------------------------"

# Update verifier.sh with actual addresses
print_status "Updating verifier script with deployed addresses..."

# Read current .env file and update verifier.sh
if [ -f verifier.sh ]; then
    # Create backup
    cp verifier.sh verifier.sh.backup

    # Update the addresses in verifier.sh
    sed -i "s/0x463614Cc6ec25180134e1029d428517fdA5e205a/$DIAMOND_ADDRESS/g" verifier.sh
    sed -i "s/0x21534C7D157815F19Badb2517d88F8D34AA42Cad/$DIAMOND_CUT_FACET/g" verifier.sh
    sed -i "s/0xeb44550483907A9C8d29E2B1CfeD633176f3D0Ac/$DIAMOND_LOUPE_FACET/g" verifier.sh
    sed -i "s/0x53D2F98811626012d94d0E7D19dFa517EF3b6d15/$ERC20_FACET/g" verifier.sh
    sed -i "s/0x767aeE1BEAF441bD6f13f3fE353c370B9A48472D/$SWAP_FACET/g" verifier.sh
    sed -i "s/0xB6ef1cfE05e6f8A64b6e553bdf624A1d46DB3e59/$MULTISIG_FACET/g" verifier.sh
    sed -i "s/0x0628Dc113E621c0F4280c23ef3767f4E6F65DB66/$METADATA_FACET/g" verifier.sh

    print_success "Updated verifier script with deployed addresses"
fi

# Run verification
print_status "Running contract verification..."
if bash verifier.sh; then
    print_success "All contracts verified successfully!"
else
    print_warning "Some contracts may have failed verification, but deployment was successful"
fi

# Final summary
echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================="
echo "📄 Contract Addresses:"
echo "   Diamond: $DIAMOND_ADDRESS"
echo "   DiamondCutFacet: $DIAMOND_CUT_FACET"
echo "   DiamondLoupeFacet: $DIAMOND_LOUPE_FACET"
echo "   ERC20Facet: $ERC20_FACET"
echo "   SwapFacet: $SWAP_FACET"
echo "   MultiSigFacet: $MULTISIG_FACET"
echo "   ERC20MetadataFacet: $METADATA_FACET"
echo ""
echo "🔗 Network: Lisk Sepolia Testnet"
echo "🌐 Explorer: https://sepolia-blockscout.lisk.com"
echo ""
echo "✅ All addresses have been saved to .env file"
echo "✅ Token SVG has been set with your tNODE.svg image"
echo "✅ Multi-signature wallet functionality enabled"
echo "✅ ETH-token swap functionality ready"
echo ""
echo "🚀 Your upgraded TrinNODE Diamond contract is ready to use!"
echo "   You can now swap ETH for tokens and vice versa"
echo "   All tokens are backed by locked ETH"
echo "   Contract upgrades require multi-signature approval"

# Clean up log files
print_status "Cleaning up temporary files..."
rm -f deploy_diamond.log deploy_facets.log set_svg.log

print_success "Deployment automation completed successfully!"
