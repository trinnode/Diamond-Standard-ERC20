// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IERC20MetadataFacet.sol";
import "../libraries/DiamondStorage.sol";

contract ERC20MetadataFacet is IERC20MetadataFacet {
    /// @notice Get the token URI containing metadata and SVG
    /// @return Token URI as JSON string with SVG image
    function tokenURI() external view override returns (string memory) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();

        // Get token metadata
        string memory name = ds.name;
        string memory symbol = ds.symbol;
        uint256 totalSupply = ds.totalSupply;

        // Get SVG image
        string memory svg = ds.tokenSVG;

        // Create JSON metadata with SVG embedded
        string memory json = string(abi.encodePacked(
            '{"name":"', name, '",',
            '"symbol":"', symbol, '",',
            '"totalSupply":"', _uint2str(totalSupply), '",',
            '"image":"data:image/svg+xml;base64,', _base64Encode(bytes(svg)), '",',
            '"description":"TrinNODE ERC20 Token with onchain SVG metadata"}'
        ));

        return json;
    }

    /// @notice Set the SVG image for the token (only multi-sig can call)
    /// @param svg SVG image data as string
    function setTokenSVG(string calldata svg) external override {
        // TODO: Add multi-sig access control
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        ds.tokenSVG = svg;
        emit TokenSVGUpdated(svg);
    }

    /// @notice Get the current SVG image
    /// @return SVG image data as string
    function getTokenSVG() external view override returns (string memory) {
        DiamondStorage.DiamondState storage ds = DiamondStorage.diamondStorage();
        return ds.tokenSVG;
    }

    /// @notice Internal function to convert uint to string
    function _uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";

        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }

        return string(bstr);
    }

    /// @notice Internal function to base64 encode bytes
    function _base64Encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // Base64 encoding implementation
        bytes memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(encodedLen + 32);

        uint256 i = 0;
        uint256 j = 0;

        for (i = 0; i < data.length - (data.length % 3); i += 3) {
            uint256 value = (uint256(uint8(data[i])) << 16) |
                           (uint256(uint8(data[i + 1])) << 8) |
                           uint256(uint8(data[i + 2]));

            result[j++] = table[(value >> 18) & 0x3F];
            result[j++] = table[(value >> 12) & 0x3F];
            result[j++] = table[(value >> 6) & 0x3F];
            result[j++] = table[value & 0x3F];
        }

        // Handle remaining bytes
        uint256 remaining = data.length % 3;
        if (remaining == 2) {
            uint256 value = (uint256(uint8(data[i])) << 16) | (uint256(uint8(data[i + 1])) << 8);
            result[j++] = table[(value >> 18) & 0x3F];
            result[j++] = table[(value >> 12) & 0x3F];
            result[j++] = table[(value >> 6) & 0x3F];
            result[j++] = bytes1('=');
        } else if (remaining == 1) {
            uint256 value = uint256(uint8(data[i]));
            result[j++] = table[(value >> 2) & 0x3F];
            result[j++] = table[(value << 4) & 0x3F];
            result[j++] = bytes1('=');
            result[j++] = bytes1('=');
        }

        return string(result);
    }
}
