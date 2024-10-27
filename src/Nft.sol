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

    constructor() ERC721("PropNFT", "PNFT") Ownable(0xE6e2595f5f910c8A6c4cf42267Ca350c6BA8c054) {}

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

        // Check if the address is whitelisted, otherwise set default membership type to Common
        if (_whitelistedAddresses[msg.sender].isWhitelisted) {
            membershipType = _whitelistedAddresses[msg.sender].membershipType;
        } else {
            membershipType = MembershipType.Common;
        }

       
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
        
       
        setTokenURIForMembership(tokenId, membershipType);
        
        // Set NFT details
        _nftDetails[tokenId] = NFTDetails(membershipType, royaltyPercentage);
        
        
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
            return 0.01 ether; 
        } else if (membershipType == MembershipType.Rare) {
            return 0.02 ether; 
        } else if (membershipType == MembershipType.Uncommon) {
            return 0.03 ether; 
        }
        return 0; 
    }

    
    function getTokenURI(MembershipType membershipType) private pure returns (string memory) {
        if (membershipType == MembershipType.Common) {
            return "QmXnxwJT4rwP4f9ubKjLwx6Wi491jffxGtF1n8Ts2rxQwa"; 
        } else if (membershipType == MembershipType.Rare) {
            return "QmPPqpqP6dhgAdMjMdMfoNeTKQnTKiqV5QMu6sFLahpFb6"; 
        } else if (membershipType == MembershipType.Uncommon) {
            return "QmPPqpqP6dhgAdMjMdMfoNeTKQnTKiqV5QMu6sFLahpFb6"; 
        }
        return ""; 
    }

    
    function setTokenURIForMembership(uint256 tokenId, MembershipType membershipType) private {
        string memory tokenURI;
        
        if (membershipType == MembershipType.Common) {
            tokenURI = "QmXnxwJT4rwP4f9ubKjLwx6Wi491jffxGtF1n8Ts2rxQwa"; 
        } else if (membershipType == MembershipType.Rare) {
            tokenURI = "QmPPqpqP6dhgAdMjMdMfoNeTKQnTKiqV5QMu6sFLahpFb6"; 
        } else if (membershipType == MembershipType.Uncommon) {
            tokenURI = "QmXnxwJT4rwP4f9ubKjLwx6Wi491jffxGtF1n8Ts2rxQwa"; 
        } else {
            tokenURI = "";
        }

        _setTokenURI(tokenId, tokenURI);
    }

    function getNFTsByOwner(address owner) public view returns (uint256[] memory) {
        uint256 totalNFTs = _tokenIdCounter; // Total number of NFTs minted
        uint256[] memory ownedNFTs = new uint256[](totalNFTs);
        uint256 count = 0;

        for (uint256 i = 0; i < totalNFTs; i++) {
            if (ownerOf(i) == owner) { 
                ownedNFTs[count] = i;
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            result[j] = ownedNFTs[j];
        }

        return result;
    }
}
