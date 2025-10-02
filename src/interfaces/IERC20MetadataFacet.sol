// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20MetadataFacet {
    /// @notice Get the token URI containing metadata and SVG
    /// @return Token URI as JSON string with SVG image
    function tokenURI() external view returns (string memory);

    /// @notice Set the SVG image for the token (only multi-sig can call)
    /// @param svg SVG image data as string
    function setTokenSVG(string calldata svg) external;

    /// @notice Get the current SVG image
    /// @return SVG image data as string
    function getTokenSVG() external view returns (string memory);

    /// @notice Events
    event TokenSVGUpdated(string svg);
}
