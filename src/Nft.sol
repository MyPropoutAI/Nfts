// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract PropNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    // Define membership types (now representing NFT types)
    enum MembershipType { Common, Rare, Uncommon, Native }

    // Struct to hold NFT details
    struct NFTDetails {
        MembershipType membershipType;
        uint256 royaltyPercentage; 
    }

    // Mapping from tokenId to NFT details
    mapping(uint256 => NFTDetails) private _nftDetails;

    // Define NFT types
    

    // Mapping to track availability of NFT types
    mapping(MembershipType => uint256) private _nftAvailability;

    // Define royalty percentages
    uint256 private constant ROYALTY_NORMAL = 5;
    uint256 private constant ROYALTY_PREMIUM = 10;
    uint256 private constant ROYALTY_PLATINUM = 15;
    uint256 private constant ROYALTY_GOLD = 20;

    // Struct to hold whitelisted addresses and their membership types
    struct WhitelistedAddress {
        MembershipType membershipType;
        bool isWhitelisted;
    }

    // Mapping to track whitelisted addresses and their membership types
    mapping(address => WhitelistedAddress) private _whitelistedAddresses;

    constructor() ERC721("PropNFT", "PNFT") Ownable(msg.sender) {}

    function mintNFT(address to, MembershipType membershipType, uint256 royaltyPercentage) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _mint(to, tokenId);
        
        // Set token URI based on membership type
        string memory tokenURI = getTokenURI(membershipType);
        _setTokenURI(tokenId, tokenURI);
        
        // Set NFT details
        _nftDetails[tokenId] = NFTDetails(membershipType, royaltyPercentage);
    }

    function mintBatchNFT(address[] memory to, MembershipType[] memory membershipTypes, uint256[] memory royaltyPercentages) public onlyOwner {
        require(to.length == membershipTypes.length, "Addresses and membershipTypes length mismatch");
        require(to.length == royaltyPercentages.length, "Addresses and royaltyPercentages length mismatch");
        
        for (uint256 i = 0; i < to.length; i++) {
            uint256 tokenId = _tokenIdCounter;
            _tokenIdCounter++;
            _mint(to[i], tokenId);
            
            // Set token URI based on membership type
            string memory tokenURI = getTokenURI(membershipTypes[i]);
            _setTokenURI(tokenId, tokenURI);
            
            // Set NFT details
            _nftDetails[tokenId] = NFTDetails(membershipTypes[i], royaltyPercentages[i]);
        }
    }

    // Function to set availability for different NFT types
    function setNFTAvailability(MembershipType nftType, uint256 availability) public onlyOwner {
        _nftAvailability[nftType] = availability;
    }

    // Function to mint NFT for whitelisted addresses
    function mintNFT(address to) public {
        
        MembershipType membershipType;
        uint256 royaltyPercentage;

        

        if (_whitelistedAddresses[msg.sender].isWhitelisted) {
            membershipType = _whitelistedAddresses[msg.sender].membershipType;
        } else {
            membershipType = MembershipType.Common; 
        }

        // Set royalty percentage based on membership type
        if (membershipType == MembershipType.Common) {
            royaltyPercentage = ROYALTY_NORMAL;
        } else if (membershipType == MembershipType.Rare) {
            royaltyPercentage = ROYALTY_PREMIUM;
        } else if (membershipType == MembershipType.Uncommon) {
            royaltyPercentage = ROYALTY_PLATINUM;
        } else if (membershipType == MembershipType.Native) {
            royaltyPercentage = ROYALTY_GOLD;
        }

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _mint(to, tokenId);
        
        // Set NFT details
        _nftDetails[tokenId] = NFTDetails(membershipType, royaltyPercentage);
        
        // Remove address from whitelist after minting
        if (_whitelistedAddresses[msg.sender].isWhitelisted) {
            _whitelistedAddresses[msg.sender].isWhitelisted = false;
        }
    }

    // Function to mint NFT with specified membership type
    function mintWithMembership(string memory tokenURI, MembershipType membershipType) public payable {
        uint256 royaltyPercentage;

        // Set royalty percentage based on membership type
        if (membershipType == MembershipType.Common) {
            royaltyPercentage = ROYALTY_NORMAL;
        } else if (membershipType == MembershipType.Rare) {
            royaltyPercentage = ROYALTY_PREMIUM;
        } else if (membershipType == MembershipType.Uncommon) {
            royaltyPercentage = ROYALTY_PLATINUM;
        } else if (membershipType == MembershipType.Native) {
            royaltyPercentage = ROYALTY_GOLD;
        } else {
            revert("Invalid membership type");
        }

        // Require payment based on membership type
        uint256 mintingFee = calculateMintingFee(membershipType);
        require(msg.value >= mintingFee, "Insufficient payment for minting");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        
        // Set NFT details
        _nftDetails[tokenId] = NFTDetails(membershipType, royaltyPercentage);
    }

    function getNFTDetails(uint256 tokenId) public view returns (MembershipType, uint256) {
        return (_nftDetails[tokenId].membershipType, _nftDetails[tokenId].royaltyPercentage);
    }

    // Function to open minting for a batch of addresses with their membership types
    function openMint(address[] memory addresses, MembershipType[] memory membershipTypes) public onlyOwner {
        require(addresses.length == membershipTypes.length, "Addresses and membershipTypes length mismatch");
        
        for (uint256 i = 0; i < addresses.length; i++) {
            _whitelistedAddresses[addresses[i]] = WhitelistedAddress(membershipTypes[i], true);
        }
    }

    // Function to calculate minting fee based on membership type
    function calculateMintingFee(MembershipType membershipType) private pure returns (uint256) {
        if (membershipType == MembershipType.Common) {
            return 0.01 ether; // Example fee for Common
        } else if (membershipType == MembershipType.Rare) {
            return 0.02 ether; // Example fee for Rare
        } else if (membershipType == MembershipType.Uncommon) {
            return 0.03 ether; // Example fee for Uncommon
        }
        return 0; // Default case
    }

    // Function to get token URI based on membership type
    function getTokenURI(MembershipType membershipType) private pure returns (string memory) {
        if (membershipType == MembershipType.Common) {
            return "ipfs://common-token-uri"; // Replace with actual URI
        } else if (membershipType == MembershipType.Rare) {
            return "ipfs://rare-token-uri"; // Replace with actual URI
        } else if (membershipType == MembershipType.Uncommon) {
            return "ipfs://uncommon-token-uri"; // Replace with actual URI
        }
        return ""; // Default case
    }
}
