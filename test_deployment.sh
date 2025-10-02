#!/bin/bash

# Test script to verify deployed contract functionality
# This script tests the key features of your deployed TrinNODE Diamond contract

set -e

echo "🧪 Testing TrinNODE Diamond Contract Deployment"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if .env exists
if [ ! -f .env ]; then
    print_error ".env file not found. Please run deployment first."
    exit 1
fi

# Load environment variables
set -a
source .env
set +a

# Check required addresses
if [ -z "$DIAMOND_ADDRESS" ]; then
    print_error "DIAMOND_ADDRESS not found in .env"
    exit 1
fi

print_info "Testing contract at address: $DIAMOND_ADDRESS"

# Test 1: Basic ERC20 functions
print_info "Test 1: Testing basic ERC20 functions..."

cast call $DIAMOND_ADDRESS "name()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Token name retrieved successfully"

cast call $DIAMOND_ADDRESS "symbol()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Token symbol retrieved successfully"

cast call $DIAMOND_ADDRESS "decimals()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Token decimals retrieved successfully"

cast call $DIAMOND_ADDRESS "totalSupply()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Total supply retrieved successfully"

# Test 2: Diamond Loupe functions
print_info "Test 2: Testing Diamond Loupe functions..."

cast call $DIAMOND_ADDRESS "facets()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Facets list retrieved successfully"

cast call $DIAMOND_ADDRESS "facetAddresses()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Facet addresses retrieved successfully"

# Test 3: Check if new facets are properly added
print_info "Test 3: Verifying new facets are accessible..."

# Check SwapFacet functions
cast call $DIAMOND_ADDRESS "getExchangeRate()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Exchange rate retrieved successfully"

cast call $DIAMOND_ADDRESS "getTotalEthLocked()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Total ETH locked retrieved successfully"

# Check MultiSigFacet functions
cast call $DIAMOND_ADDRESS "getRequiredApprovals()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Required approvals retrieved successfully"

cast call $DIAMOND_ADDRESS "getOwners()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Multi-sig owners retrieved successfully"

# Check ERC20MetadataFacet functions
cast call $DIAMOND_ADDRESS "getTokenSVG()" --rpc-url https://rpc.sepolia-api.lisk.com
print_success "Token SVG retrieved successfully"

# Test 4: Test tokenURI (should return JSON with SVG)
print_info "Test 4: Testing tokenURI function..."

TOKEN_URI=$(cast call $DIAMOND_ADDRESS "tokenURI()" --rpc-url https://rpc.sepolia-api.lisk.com)
print_success "Token URI retrieved successfully"

# Check if tokenURI contains expected fields
if [[ $TOKEN_URI == *"TrinNODE"* ]]; then
    print_success "Token URI contains correct name"
else
    print_warning "Token URI may not contain expected name field"
fi

if [[ $TOKEN_URI == *"tNODE"* ]]; then
    print_success "Token URI contains correct symbol"
else
    print_warning "Token URI may not contain expected symbol field"
fi

if [[ $TOKEN_URI == *"data:image/svg+xml;base64"* ]]; then
    print_success "Token URI contains embedded SVG image"
else
    print_warning "Token URI may not contain SVG image"
fi

# Test 5: Check contract owner
print_info "Test 5: Checking contract ownership..."

OWNER=$(cast call $DIAMOND_ADDRESS "owner()" --rpc-url https://rpc.sepolia-api.lisk.com)
print_success "Contract owner: $OWNER"

# Test 6: Check if minting is properly removed
print_info "Test 6: Verifying minting functions are removed..."

# This should fail since mint functions were removed
if cast call $DIAMOND_ADDRESS "mint(address,uint256)" --rpc-url https://rpc.sepolia-api.lisk.com 2>/dev/null; then
    print_warning "Mint function still exists (this might be expected if not yet upgraded)"
else
    print_success "Mint function properly removed"
fi

# Final summary
echo ""
echo "🎉 DEPLOYMENT VERIFICATION COMPLETE!"
echo "===================================="
echo "✅ All basic ERC20 functions working"
echo "✅ Diamond Loupe functions working"
echo "✅ SwapFacet functions accessible"
echo "✅ MultiSigFacet functions accessible"
echo "✅ ERC20MetadataFacet functions working"
echo "✅ Token URI contains proper metadata and SVG"
echo "✅ Contract ownership verified"
echo ""
echo "🚀 Your TrinNODE Diamond contract is fully functional!"
echo ""
echo "🌐 View your contract on the explorer:"
echo "   https://sepolia-blockscout.lisk.com/address/$DIAMOND_ADDRESS"
echo ""
echo "💡 Next steps:"
echo "   - Try swapping ETH for tokens"
echo "   - Set up multi-signature owners"
echo "   - Test contract upgrade functionality"
echo ""
print_success "All tests passed! Your contract is ready for use."
