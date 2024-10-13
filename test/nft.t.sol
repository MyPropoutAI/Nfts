// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Test.sol";
import "../src/Nft.sol";

contract MyNFTTest is Test {
    MyNFT myNFT;
    address owner = mkaddr("owner");
    address user1 = mkaddr("user1");
    address user2 = mkaddr("user2");

    function setUp() public {
        vm.startPrank(owner);
        myNFT = new MyNFT();
        vm.stopPrank();
    }

    function testMintNFT() public {
        vm.startPrank(owner);
        myNFT.mintNFT(user1, "https://token-uri.com/1");
        assertEq(myNFT.ownerOf(0), user1);
        vm.stopPrank();
    }

    function testTransferNFT() public {
        testMintNFT();
        vm.startPrank(user1);
        myNFT.transferFrom(user1, user2, 0);
        assertEq(myNFT.ownerOf(0), user2);
        vm.stopPrank();
    }

    function testApproveAndTransferNFT() public {
        testMintNFT();
        vm.startPrank(user1);
        myNFT.approve(user2, 0);
        vm.stopPrank();

        vm.startPrank(user2);
        myNFT.transferFrom(user1, user2, 0);
        assertEq(myNFT.ownerOf(0), user2);
        vm.stopPrank();
    }

    function testFailTransferWithoutApproval() public {
        testMintNFT();
        vm.startPrank(user2);
        vm.expectRevert("ERC721: transfer caller is not owner nor approved");
        myNFT.transferFrom(user1, user2, 0);
        vm.stopPrank();
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}
