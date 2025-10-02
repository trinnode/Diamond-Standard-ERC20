#!/bin/bash

# --- Configuration ---
# This script automates the verification of multiple Foundry contracts on Lisk Sepolia testnet using Blockscout.
#
# Instructions:
# 1. Fill in your contract addresses in the `ADDRESSES` array.
# 2. Fill in the corresponding contract paths and names in the `CONTRACTS` array.
# 3. Save the file (e.g., as verify_contracts.sh).
# 4. Make it executable by running: chmod +x verify_contracts.sh
# 5. Run the script from your project's root directory: ./verify_contracts.sh

# Exit immediately if any command fails
set -e

# --- Lisk Network and Verifier Details (These are constant) ---
RPC_URL="https://rpc.sepolia-api.lisk.com"
VERIFIER_URL="https://sepolia-blockscout.lisk.com/api/"
VERIFIER="blockscout"

# --- USER: PLEASE EDIT THE ARRAYS BELOW ---

# Add your 6 deployed contract addresses here
# The first one is from your example. Replace the others with your actual addresses.



declare -a ADDRESSES=(
        "0xCD34f50b651374671C74781757d85faa75e5431e"
        "0xe6F30F30E8E434E32a3a9F175225D6A987ccEFA9"
        "0xA4F938313Fd6535E09004CE1573E0eED301A4179"
        "0x163807291899cc788b8b0e26752B67CfE3A3e796"
        "0xDfFCB26B25aB8FA5d4522f7226c51dAc5b1771F2"
        "0xAB4c880C2736Cc9C54D195102b45c35C825aEf7b"
        "0xc8B5A34BC6791138d107E1348A24bB7c27C766e4"
)

# Add the corresponding contract paths and names here, in the same order as the addresses above.
# Format: path/to/ContractFile.sol:ContractName
declare -a CONTRACTS=(  
  "src/Diamond.sol:Diamond"
  "src/facets/DiamondCutFacet.sol:DiamondCutFacet"
  "src/facets/DiamondLoupeFacet.sol:DiamondLoupeFacet"
  "src/facets/ERC20Facet.sol:ERC20Facet"
  "src/facets/SwapFacet.sol:SwapFacet"
  "src/facets/MultiSigFacet.sol:MultiSigFacet"
  "src/facets/ERC20MetadataFacet.sol:ERC20MetadataFacet"
)

# --- Verification Logic (No need to edit below this line) ---

echo "Starting contract verification process for Lisk Sepolia Testnet..."
echo ""

# Check if the number of addresses matches the number of contracts
if [ ${#ADDRESSES[@]} -ne ${#CONTRACTS[@]} ]; then
    echo "Error: The number of addresses does not match the number of contracts. Please check the arrays."
    exit 1
fi

# Loop through the arrays and verify each contract
for i in "${!ADDRESSES[@]}"; do
  ADDRESS="${ADDRESSES[$i]}"
  CONTRACT_PATH_NAME="${CONTRACTS[$i]}"
  
  # Extract just the contract name for a cleaner output message
  CONTRACT_NAME=$(echo "$CONTRACT_PATH_NAME" | cut -d ':' -f 2)

  echo "----------------------------------------------------------------"
  echo "Verifying ${CONTRACT_NAME} at address ${ADDRESS}..."
  echo "----------------------------------------------------------------"

  # Execute the forge verification command
  forge verify-contract \
    --rpc-url "$RPC_URL" \
    --verifier "$VERIFIER" \
    --verifier-url "$VERIFIER_URL" \
    "$ADDRESS" \
    "$CONTRACT_PATH_NAME"

  echo "✅ Successfully executed verification for ${CONTRACT_NAME}."
  echo ""
done

echo "================================================================"
echo "All contract verification commands have been executed."
echo "Please check the output above for the status of each contract."
echo "================================================================"
