// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MyNFT", "MNFT") {}

    function mintNFT(address to, string memory tokenURI) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }
}
