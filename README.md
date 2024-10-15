## Verified Contract Information

### Contract Address

- **Address:** [0xf4a02703f125EDC2bf1518c4398B8766ec3212Ba](https://sepolia-blockscout.lisk.com/address/0xf4a02703f125EDC2bf1518c4398B8766ec3212Ba)

### Explorer URL

- **Blockscout Explorer:** [View Contract on Sepolia Blockscout](https://sepolia-blockscout.lisk.com/address/0xf4a02703f125EDC2bf1518c4398B8766ec3212Ba)


# PropNFT Contract Documentation

## Overview
The `PropNFT` contract is an ERC721-based NFT (Non-Fungible Token) implementation that allows the minting of NFTs with different membership types. It includes features for managing whitelisted addresses, setting royalty percentages, and handling batch minting.

## Key Components

### Membership Types
The contract defines four membership types using an enum:
- `Common`
- `Rare`
- `Uncommon`
- `Native`

### Structs
- **NFTDetails**: Holds details about each NFT, including its membership type and royalty percentage.
- **WhitelistedAddress**: Tracks whether an address is whitelisted and its associated membership type.

### Mappings
- `_nftDetails`: Maps token IDs to their corresponding NFT details.
- `_nftAvailability`: Tracks the availability of different NFT types.
- `_whitelistedAddresses`: Maps addresses to their whitelisted status and membership type.



### Minting Functions
- **mintNFT**: 
  ```solidity
  function mintNFT(address to, MembershipType membershipType, uint256 royaltyPercentage) public onlyOwner
  ```
  Mints a single NFT for a specified address with a given membership type and royalty percentage.

- **mintBatchNFT**: 
  ```solidity
  function mintBatchNFT(address[] memory to, MembershipType[] memory membershipTypes, uint256[] memory royaltyPercentages) public onlyOwner
  ```
  Mints multiple NFTs in a single transaction for an array of addresses, each with specified membership types and royalty percentages.

- **mintNFT (whitelisted)**: 
  ```solidity
  function mintNFT(address to) public
  ```
  Allows whitelisted addresses to mint an NFT based on their membership type.

- **mintWithMembership**: 
  ```solidity
  function mintWithMembership(string memory tokenURI, MembershipType membershipType) public payable
  ```
  Mints an NFT with a specified membership type and requires payment based on the type.

### Utility Functions
- **getNFTDetails**: 
  ```solidity
  function getNFTDetails(uint256 tokenId) public view returns (MembershipType, uint256)
  ```
  Returns the membership type and royalty percentage for a given token ID.

- **openMint**: 
  ```solidity
  function openMint(address[] memory addresses, MembershipType[] memory membershipTypes) public onlyOwner
  ```
  Whitelists a batch of addresses with their corresponding membership types.

- **calculateMintingFee**: 
  ```solidity
  function calculateMintingFee(MembershipType membershipType) private pure returns (uint256)
  ```
  Calculates the minting fee based on the membership type.

- **getTokenURI**: 
  ```solidity
  function getTokenURI(MembershipType membershipType) private pure returns (string memory)
  ```
  Returns the token URI based on the membership type.

## Royalty Percentages
The contract defines constant royalty percentages for different membership types:
- `ROYALTY_NORMAL`: 5%
- `ROYALTY_PREMIUM`: 10%
- `ROYALTY_PLATINUM`: 15%
- `ROYALTY_GOLD`: 20%


